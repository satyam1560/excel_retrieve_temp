// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';

// class ClodFunction extends StatelessWidget {
//   const ClodFunction({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Center(
//         child: ElevatedButton(
//             onPressed: () {
//               FirebaseFirestore.instance
//                   .collection('Students')
//                   .doc('5bjz4LoJI0fioITh1E4w')
//                   .set({'caste': 'hindu'});
//             },
//             child: const Text('CloudFunction')),
//       ),
//     );
//   }
// }
//!
// Future<void> uploadToStaffSubjectAllocation({
//   required CollectionReference collectionRef,
//   required String schoolId,
//   required List<Map<String, dynamic>> dataList,
// }) async {
//   try {
//     await FirebaseFirestore.instance.runTransaction((transaction) async {
//       for (var data in dataList) {
//         String name = data['staff_name'];
//         Map<String, dynamic> subject = {
//           'grade': data['grade'],
//           'section': data['sections'],
//           'subjectname': data['subject_name']
//         };
//         QuerySnapshot querySnapshot = await FirebaseFirestore.instance
//             .collection('Staff')
//             .where('schoolID', isEqualTo: collectionRef.doc(schoolId))
//             .where('name', isEqualTo: name)
//             .get();

//         for (var doc in querySnapshot.docs) {
//           var docData = doc.data() as Map<String, dynamic>;
//           var existingSubjects = docData.containsKey('subjects')
//               ? List<Map<String, dynamic>>.from(docData['subjects'])
//               : [];

//           // Check if subject already exists
//           bool subjectExists = existingSubjects.any((s) =>
//               s['grade'] == subject['grade'] &&
//               s['section'] == subject['section'] &&
//               s['subjectname'] == subject['subjectname']);

//           if (!subjectExists) {
//             // Add the subject to the list of subjects
//             existingSubjects.add(subject);

//             // Update the document in Firestore
//             transaction.update(
//               FirebaseFirestore.instance.collection('Staff').doc(doc.id),
//               {
//                 'subjects': FieldValue.arrayUnion([subject])
//               },
//             );

//             // Set the staff reference
//             DocumentReference staffRef =
//                 FirebaseFirestore.instance.collection('Staff').doc(doc.id);

//             // Add the subject allocation document
//             transaction.set(
//               FirebaseFirestore.instance
//                   .collection('Schools')
//                   .doc(schoolId)
//                   .collection('SubjectAllocation')
//                   .doc(),
//               {'tid': staffRef, 'tName': name, ...subject},
//             );
//           }
//         }
//       }
//     });
//   } catch (e) {
//     debugPrint('Error uploading to Firestore: $e');
//     rethrow;
//   }
// }
