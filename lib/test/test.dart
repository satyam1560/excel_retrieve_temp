

// Future<void> uploadToStaffSubjectAllocation({
//   // required WriteBatch batch,
//   // required CollectionReference collref,
//   required String schoolId,
//   required List<Map<String, dynamic>> dataList,
// }) async {
//   for (var data in dataList) {
//     String name = data['staff_name'];
//     Map<String, dynamic> subject = {
//       'grade': data['grade'],
//       'section': data['sections'],
//       'subjectname': data['subject_name']
//     };
//     print('data $data');
//     QuerySnapshot querySnapshot = await FirebaseFirestore.instance
//         .collection('Staff')
//         .where('sclId', isEqualTo: schoolId)
//         .where('name', isEqualTo: name)
//         .get();
//     print('queryshapst${querySnapshot.docs}');
//     for (var doc in querySnapshot.docs) {
//       print('doc$doc');
//       print('doc data${doc.data()}');
//       var docData = doc.data() as Map<String, dynamic>;
//       var existingSubjects = docData.containsKey('subjects')
//           ? List<Map<String, dynamic>>.from(docData['subjects'])
//           : [];
//       print('existingSubjects $existingSubjects');
//       // Check if subject already exists
//       bool subjectExists = existingSubjects.any((s) =>
//           s['grade'] == subject['grade'] &&
//           s['section'] == subject['section'] &&
//           s['subjectname'] == subject['subjectname']);

//       if (!subjectExists) {
//         // Add the subject to the list of subjects
//         existingSubjects.add(subject);
//         DocumentReference staffRef = firestore.collection('Staff').doc(doc.id);

//         // Update the document in Firestore
//         await firestore
//             .collection('Staff')
//             .doc(doc.id)
//             .update({'subjects': existingSubjects}).then((value) => firestore
//                 .collection('Schools')
//                 .doc(schoolId)
//                 .collection('SubjectAllocation')
//                 .doc()
//                 .set({'tid': staffRef, 'tName': name, ...subject}));
//       }
//     }
//   }
// }