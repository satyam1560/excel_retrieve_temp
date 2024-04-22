// The Cloud Functions for Firebase SDK to create Cloud Functions and triggers.
// const {logger} = require("firebase-functions");
const {onRequest} = require("firebase-functions/v2/https");
// const {onDocumentCreated} = require("firebase-functions/v2/firestore");

// The Firebase Admin SDK to access Firestore.
const {initializeApp} = require("firebase-admin/app");
const {getFirestore} = require("firebase-admin/firestore");

initializeApp();

exports.addStudentCaste = onRequest(async (req, res) => {
  const db = getFirestore();
  const documentId = req.params.documentId;
  const caste = req.query.caste;

  try {
    // Update /religious/:documentId/hindu
    const religiousRef = db.collection("Religion").doc(documentId);
    const religiousDoc = await religiousRef.get();

    if (!religiousDoc.exists) {
      throw new Error("Religious document does not exist.");
    }

    const hinduCount = religiousDoc.data().hindu || 0;
    const updatedHinduCount = hinduCount + 1;

    await religiousRef.update({hindu: updatedHinduCount});

    // Add the caste to /students/:documentId/caste
    const studentRef = db.collection("Students").doc(documentId);
    await studentRef.set({caste});

    res.json({message: "Caste added successfully."});
  } catch (error) {
    console.error("Error adding caste:", error);
    res.status(500).json({error: "Failed to add caste."});
  }
});
