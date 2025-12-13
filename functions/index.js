import { onDocumentCreated } from "firebase-functions/v2/firestore";
import { initializeApp } from "firebase-admin/app";
import { getFirestore } from "firebase-admin/firestore";
import { getMessaging } from "firebase-admin/messaging";

initializeApp();
const db = getFirestore();


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
