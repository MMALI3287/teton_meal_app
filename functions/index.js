const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

exports.updatePollStatus = functions.pubsub
  .schedule("every 1 minutes")
  .onRun(async (context) => {
    const now = Date.now();
    const pollsRef = admin.firestore().collection("polls");
    const snapshot = await pollsRef.where("isActive", "==", true).get();

    snapshot.forEach(async (doc) => {
      const poll = doc.data();
      if (poll.endTimeMillis <= now) {
        await pollsRef.doc(doc.id).update({ isActive: false });
      }
    });

    return null;
  });
