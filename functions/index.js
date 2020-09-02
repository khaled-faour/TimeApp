const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp(functions.config().firebase);
// // Create and Deploy Your First Cloud Functions
// // https://firebase.google.com/docs/functions/write-firebase-functions
//
// exports.helloWorld = functions.https.onRequest((request, response) => {
//   functions.logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });


exports.createUserDocument = functions.auth.user().onCreate(async (user) => {
    const addUserFirstTask = admin.firestore().collection("Users/" + user.uid + "/Category");
    try {
        await addUserFirstTask.add({
            taskTitle: "First Task"
        });
    } catch (e) {
        console.log(e);
    }
});