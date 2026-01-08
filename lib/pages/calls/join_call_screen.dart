import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../../models/meeting_model.dart';
import '../../../../services/user_manager.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'payment_api.dart';

class VideoCallScreen extends StatefulWidget {
  final Meeting meeting;

  const VideoCallScreen({super.key, required this.meeting});

  @override
  State<VideoCallScreen> createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen> {
  late RtcEngine engine;
  int? remoteUid;
  bool localJoined = false;

  bool mutedMic = false;
  bool cameraOff = false;
  bool localCameraOff = false;
  bool remoteCameraOff = false;
  bool _exiting = false;
  int seconds = 0;
  Timer? timer;
  late int myUid;

  @override
  void initState() {
    super.initState();
    myUid = UserManager().isLawyer ? 1 : 2;
    initializeAgora();
    FirebaseFirestore.instance
        .collection("meetings")
        .doc(widget.meeting.id)
        .snapshots()
        .listen((doc) async {
          if (doc.exists && doc.data()?['callCompleted'] == true) {
            await _exitCall();
          }
        });
  }

  Future<void> _exitCall() async {
    if (_exiting) return;
    _exiting = true;

    timer?.cancel();
    await engine.leaveChannel();
    await engine.release();

    if (mounted) Navigator.pop(context);
  }

  Future<String> fetchAgoraToken() async {
    final url = Uri.parse(
      "https://us-central1-nyayaconnect-free.cloudfunctions.net/generateAgoraToken"
      "?channelId=${widget.meeting.channelId}&uid=$myUid",
    );

    final res = await http.get(url);
    if (res.statusCode == 200) {
      return jsonDecode(res.body)["token"];
    } else {
      throw Exception("Failed to fetch token");
    }
  }

  Future<void> initializeAgora() async {
    await Permission.camera.request();
    await Permission.microphone.request();

    // 1️⃣ CREATE ENGINE
    engine = createAgoraRtcEngine();

    // 2️⃣ INITIALIZE
    await engine.initialize(
      const RtcEngineContext(appId: "6c4f9baff3694449bc5cf698b94a582a"),
    );

    // 3️⃣ REGISTER EVENTS
    engine.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          setState(() => localJoined = true);

          FirebaseFirestore.instance
              .collection("calls")
              .doc(widget.meeting.id)
              .set({
                "meetingId": widget.meeting.id,
                "lawyerId": widget.meeting.lawyerId,
                "lawyerName": widget.meeting.lawyerName,
                "clientId": widget.meeting.clientId,
                "clientName": widget.meeting.clientName,
                "startedAt": FieldValue.serverTimestamp(),
              }, SetOptions(merge: true));
        },

        onUserJoined: (RtcConnection connection, int uid, int elapsed) {
          setState(() => remoteUid = uid);
          if (timer == null) startTimer();
        },

        onRemoteVideoStateChanged:
            (
              RtcConnection connection,
              int uid,
              RemoteVideoState state,
              RemoteVideoStateReason reason,
              int elapsed,
            ) {
              if (uid == remoteUid) {
                if (state == RemoteVideoState.remoteVideoStateStopped ||
                    state == RemoteVideoState.remoteVideoStateFrozen) {
                  setState(() => remoteCameraOff = true);
                } else if (state == RemoteVideoState.remoteVideoStateDecoding) {
                  setState(() => remoteCameraOff = false);
                }
              }
            },

        onUserOffline:
            (
              RtcConnection connection,
              int uid,
              UserOfflineReasonType reason,
            ) async {
              setState(() => remoteUid = null);

              final now = FieldValue.serverTimestamp();

              await FirebaseFirestore.instance
                  .collection("calls")
                  .doc(widget.meeting.id)
                  .set({
                    "endedAt": now,
                    "durationSeconds": seconds,
                  }, SetOptions(merge: true));

              final amount = await _calculateAmount();

              await FirebaseFirestore.instance
                  .collection("meetings")
                  .doc(widget.meeting.id)
                  .update({
                    "callCompleted": true,
                    "updatedAt": now,
                    "durationSeconds": seconds,
                    "amount": amount,
                    "paymentStatus": "blocked",
                    "summaryUploaded": false,
                  });
              final meetingRef = FirebaseFirestore.instance
                  .collection("meetings")
                  .doc(widget.meeting.id);

              final snap = await meetingRef.get();

              if (snap.data()?['razorpayOrderId'] == null) {
                final order = await createOrder(widget.meeting.id, amount);
                await meetingRef.update({"razorpayOrderId": order['id']});
              }

              await _exitCall();
            },
      ),
    );

    // 4️⃣ VIDEO SETUP
    await engine.enableVideo();
    await engine.startPreview();

    // 5️⃣ JOIN CHANNEL
    final token = await fetchAgoraToken();
    await engine.joinChannel(
      token: token,
      channelId: widget.meeting.channelId,
      uid: myUid,
      options: const ChannelMediaOptions(
        clientRoleType: ClientRoleType.clientRoleBroadcaster,
      ),
    );
  }

  Future<int> _calculateAmount() async {
    final lawyerDoc = await FirebaseFirestore.instance
        .collection('lawyer_details')
        .doc(widget.meeting.lawyerId)
        .get();

    final chargesPerHour = (lawyerDoc.data()?['chargesPerHour'] ?? 0)
        .toDouble();

    final perMinute = chargesPerHour / 60;
    final minutes = (seconds / 60).ceil(); // round up
    final totalAmount = (perMinute * minutes).round();

    return totalAmount;
  }

  void startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => seconds++);
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  String get callDuration {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return "$m:$s";
  }

  Widget _videoPlaceholder(String name) {
    final initial = name.isNotEmpty ? name[0].toUpperCase() : "?";

    return Container(
      color: Colors.grey.shade900,
      alignment: Alignment.center,
      child: CircleAvatar(
        radius: 40,
        backgroundColor: Colors.grey.shade700,
        child: Text(
          initial,
          style: const TextStyle(
            fontSize: 36,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: Stack(
                  children: [
                    if (remoteUid != null)
                      AgoraVideoView(
                        controller: VideoViewController.remote(
                          rtcEngine: engine,
                          connection: RtcConnection(
                            channelId: widget.meeting.channelId,
                          ),
                          canvas: VideoCanvas(uid: remoteUid),
                        ),
                      ),

                    if (remoteUid != null && remoteCameraOff)
                      _videoPlaceholder(
                        UserManager().isLawyer
                            ? widget.meeting.clientName
                            : widget.meeting.lawyerName,
                      ),
                  ],
                ),
              ),

              Expanded(
                child: Stack(
                  children: [
                    if (localJoined)
                      AgoraVideoView(
                        controller: VideoViewController(
                          rtcEngine: engine,
                          canvas: const VideoCanvas(uid: 0),
                        ),
                      ),

                    if (localCameraOff)
                      _videoPlaceholder(
                        UserManager().isLawyer
                            ? widget.meeting.lawyerName
                            : widget.meeting.clientName,
                      ),
                  ],
                ),
              ),
            ],
          ),

          /// TIMER
          Positioned(
            top: 40,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  callDuration,
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
            ),
          ),

          /// CONTROLS
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                CircleAvatar(
                  backgroundColor: Colors.white24,
                  child: IconButton(
                    icon: Icon(
                      mutedMic ? Icons.mic_off : Icons.mic,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      setState(() => mutedMic = !mutedMic);
                      engine.muteLocalAudioStream(mutedMic);
                    },
                  ),
                ),

                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.red,
                  child: IconButton(
                    icon: const Icon(Icons.call_end, color: Colors.white),
                    iconSize: 32,
                    onPressed: () async {
                      final now = FieldValue.serverTimestamp();

                      // 1️⃣ Update CALL LOG
                      await FirebaseFirestore.instance
                          .collection("calls")
                          .doc(widget.meeting.id)
                          .set({
                            "endedAt": now,
                            "durationSeconds": seconds,
                          }, SetOptions(merge: true));

                      // 2️⃣ UPDATE MEETING STATE (CRITICAL)
                      final amount = await _calculateAmount();

                      await FirebaseFirestore.instance
                          .collection("meetings")
                          .doc(widget.meeting.id)
                          .update({
                            "callCompleted": true,
                            "updatedAt": now,
                            "durationSeconds": seconds,
                            "amount": amount,
                            "paymentStatus": "pending",
                          });
                      final meetingRef = FirebaseFirestore.instance
                          .collection("meetings")
                          .doc(widget.meeting.id);

                      final snap = await meetingRef.get();

                      if (snap.data()?['razorpayOrderId'] == null) {
                        final order = await createOrder(
                          widget.meeting.id,
                          amount,
                        );
                        await meetingRef.update({
                          "razorpayOrderId": order['id'],
                        });
                      }
                    },
                  ),
                ),

                CircleAvatar(
                  backgroundColor: Colors.white24,
                  child: IconButton(
                    icon: Icon(
                      cameraOff ? Icons.videocam_off : Icons.videocam,
                      color: Colors.white,
                    ),
                    onPressed: () async {
                      setState(() => localCameraOff = !localCameraOff);
                      engine.muteLocalVideoStream(localCameraOff);
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
