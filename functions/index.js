import { onDocumentCreated } from "firebase-functions/v2/firestore";
import { initializeApp } from "firebase-admin/app";
import { getFirestore } from "firebase-admin/firestore";
import { getMessaging } from "firebase-admin/messaging";
import { onRequest } from "firebase-functions/v2/https";
import pkg from "agora-token";
import Razorpay from "razorpay";
import { defineSecret } from "firebase-functions/params";



initializeApp();
const db = getFirestore();
const { RtcRole, RtcTokenBuilder } = pkg;
const AGORA_APP_ID = "6c4f9baff3694449bc5cf698b94a582a";
const AGORA_APP_CERT = "71c1adce3f67452380b42d91243a9986";
const RAZORPAY_KEY_ID = defineSecret("RAZORPAY_KEY_ID");
const RAZORPAY_KEY_SECRET = defineSecret("RAZORPAY_KEY_SECRET");



export const sendPushNotification = onDocumentCreated(
  "notifications/{notificationId}",
  async (event) => {
    const data = event.data.data();

    if (!data) {
      console.log("No notification data found.");
      return;
    }

    const userId = data.userId;
    const title = data.title || "New Notification";
    const message = data.message || "You have a new update";

    if (!userId) {
      console.log("Missing userId in notification document");
      return;
    }

    // Fetch user's FCM token
    const userDoc = await db.collection("users").doc(userId).get();

    if (!userDoc.exists) {
      console.log("User does not exist");
      return;
    }

    const fcmToken = userDoc.get("fcmToken");

    if (!fcmToken) {
      console.log("User does not have any FCM token");
      return;
    }


    try {
      await getMessaging().send({
        token: fcmToken,
        notification: {
          title: title,
          body: message,
        },
      });

      console.log("📨 Notification sent successfully to:", userId);
    } catch (error) {
      console.error("🔥 Error sending notification:", error);
    }
  }
);
export const generateAgoraToken = onRequest({ cors: true }, async (req, res) => {
  const channelId = req.query.channelId;
  const uid = Number(req.query.uid || 0);

  if (!channelId) {
    res.status(400).send("Missing channelId");
    return;
  }

  const expireSeconds = 3600;
  const now = Math.floor(Date.now() / 1000);

  const token = RtcTokenBuilder.buildTokenWithUid(
    AGORA_APP_ID,
    AGORA_APP_CERT,
    channelId,
    uid,
    RtcRole.PUBLISHER,
    now + expireSeconds
  );

  res.json({ token });
});
export const createPaymentOrder = onRequest(
  {
    cors: true,
    secrets: [RAZORPAY_KEY_ID, RAZORPAY_KEY_SECRET],
  },
  async (req, res) => {
    try {
      const razorpay = new Razorpay({
        key_id: RAZORPAY_KEY_ID.value(),
        key_secret: RAZORPAY_KEY_SECRET.value(),
      });

      const { meetingId, amount } = req.body;

      if (!meetingId || !amount) {
        return res.status(400).send("Missing data");
      }

      const order = await razorpay.orders.create({
        amount: amount * 100,
        currency: "INR",
        receipt: meetingId,
      });

      res.json(order);
    } catch (err) {
      console.error(err);
      res.status(500).send("Payment order failed");
    }
  }
);
