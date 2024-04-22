import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          child: ElevatedButton(
            onPressed: () {
              selectOnboardingExcelFile();
            },
            child: const Text('Excel update'),
          ),
        ),
      ],
    );
  }
}

FirebaseFirestore firestore = FirebaseFirestore.instance;
CollectionReference schoolCollectionReference = firestore.collection('Schools');
WriteBatch schoolBatch = firestore.batch();
WriteBatch classBatch = firestore.batch();
WriteBatch staffBatch = firestore.batch();
WriteBatch studentBatch = firestore.batch();
WriteBatch feesSetupBatch = firestore.batch();

Future<bool> selectOnboardingExcelFile() async {
  try {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
      withData: true,
    );

    if (result == null) {
      return false;
    }

    var bytes = result.files.first.bytes!;
    var excel = Excel.decodeBytes(bytes);
    var listOfSheets = excel.tables.keys.toList();

    String schoolDocId = 'uw5HHEKDKZ2CgIBh1gpW';

    for (var excelSheet in listOfSheets) {
      List<Map<String, dynamic>> excelData =
          traverseExcelData(excel.tables[excelSheet]!);

      if (excelData.isNotEmpty) {
        if (excelSheet == 'School Basic Information') {
          // schoolDocId = await uploadToSchoolBasicInformation(
          //   schoolBatch: schoolBatch,
          //   schoolCollection: 'Schools',
          //   excelData: excelData,
          // );
          // await schoolBatch.commit();
        }
        if (excelSheet == 'Registration Details') {
          registrationDetails(
            collectionName: 'Schools',
            excelData: excelData,
            schoolDocId: schoolDocId,
          );
        }
        if (excelSheet == 'Fees Setup') {
          // await uploadToFeesSetup(
          //   excelData: excelData,
          //   schoolDocId: schoolDocId,
          // );
        }
        if (excelSheet == 'Classes Information') {
          // await uploadToClassInformation(
          //   classBatch: classBatch,
          //   excelData: excelData,
          //   schoolId: schoolDocId,
          //   schoolCollection: 'Schools',
          // );
          // await classBatch.commit();
        }
        if (excelSheet == 'Staff Information') {
          // await uploadToStaffInformation(
          //   staffBatch: staffBatch,
          //   staffCollection: 'Staff',
          //   excelData: excelData,
          //   schoolId: schoolDocId,
          // );
          // await staffBatch.commit();
        }
        if (excelSheet == 'Student Information') {
          // await uploadToStudentInformation(
          //   studentBatch: studentBatch,
          //   studentCollection: 'Students',
          //   excelData: excelData,
          //   schoolId: schoolDocId,
          // );
          // await studentBatch.commit();
        }
        if (excelSheet == 'Subject Allocation') {
          // await uploadToSubjectAllocation(
          //   schoolCollectionReference: schoolCollectionReference,
          //   excelData: excelData,
          //   schoolId: schoolDocId,
          // );
        }
      } else {
        return false;
      }
    }
    return true;
  } catch (e) {
    debugPrint('Error processing Excel file: $e');
    return false;
  }
}

//* registration Details
//* -------------------------------------------------------------
void registrationDetails({
  required List<Map<String, dynamic>> excelData,
  required String schoolDocId,
  required String collectionName,
}) async {
  // print('excel deata $excelData');
  List<Map<String, dynamic>> registrationdetails = [];
  for (var element in excelData) {
    Map<String, dynamic> schoolRegistrationNum = {
      'registrationNum': element['registration_number'],
      'schoolName': element['school_name'],
      'udiseNum': element['udiseNum'],
      'affiliationBoard': element['affiliation_board'],
    };
    List<String> grades = element['grades'].split(',');
    Map<String, dynamic> oneformat = {
      'schoolRegistrationNum': schoolRegistrationNum,
      'grades': grades
    };
    registrationdetails.add(oneformat);
  }
  await schoolCollectionReference
      .doc(schoolDocId)
      .set({'registrationdetails': registrationdetails});
}

//* Fees Setup
//* -------------------------------------------------------------
Future<void> uploadToFeesSetup(
    {required List<Map<String, dynamic>> excelData,
    required String schoolDocId}) async {
  try {
    for (var element in excelData) {
      final instName = element['instName'];
      List<String> itemNamels = element['itemName'].split(',');
      List<String> itemFeesls = element['itemFees'].split(',');
      List<String> forNewStudls = element['forNewStud'].split(',');
      List<String> gradels = element['grade'].split(',');

      List<Map<String, dynamic>> data = [];
      for (int i = 0; i < itemNamels.length; i++) {
        double itemFee = double.parse(itemFeesls[i]);
        bool forNewStudent = forNewStudls[i] == 'true' ? true : false;
        data.add({
          'itemName': itemNamels[i],
          'itemFees': itemFee,
          'forNewStud': forNewStudent,
        });
      }

      final Map<String, dynamic> feesSetup = {
        'data': data,
        'grades': gradels,
        'instName': instName,
      };

      DocumentReference docRef = schoolCollectionReference
          .doc(schoolDocId)
          .collection('FeesSetup')
          .doc();
      feesSetupBatch.set(docRef, feesSetup);
    }
  } catch (e) {
    rethrow;
  }

  await feesSetupBatch.commit();
}

//* Subject Allocation
//* -------------------------------------------------------------

Future<void> uploadToSubjectAllocation({
  required CollectionReference schoolCollectionReference,
  required String schoolId,
  required List<Map<String, dynamic>> excelData,
}) async {
  CollectionReference staffCollectionReference =
      FirebaseFirestore.instance.collection('Staff');
  WriteBatch subAllBatch = FirebaseFirestore.instance.batch();

  try {
    for (var staff in excelData) {
      String tName = staff['staff_name'];
      String grade = staff['grade'];
      String sections = staff['sections'];
      String subjects = staff['subject_name'];

      List<String> sectionList = sections.split(',');
      List<String> subjectList = subjects.split(',');
      List<Map<String, String>> staffSubjects = [];

      Map<String, dynamic> subjectAllocation = {};

      QuerySnapshot querySnapshot = await staffCollectionReference
          .where('schoolID', isEqualTo: schoolCollectionReference.doc(schoolId))
          .where('name', isEqualTo: tName)
          .get();

      var doc = querySnapshot.docs[0];

      for (String section in sectionList) {
        for (String subject in subjectList) {
          staffSubjects.add(
            {
              'grade': grade,
              'section': section.trim(),
              'subject': subject.trim()
            },
          );

          subjectAllocation['grade'] = grade;
          subjectAllocation['section'] = section.trim();
          subjectAllocation['subject'] = subject.trim();
          subjectAllocation['tName'] = tName;
          subjectAllocation['tid'] = staffCollectionReference.doc(doc.id);

          subAllBatch.set(
            schoolCollectionReference
                .doc(schoolId)
                .collection('SubjectAllocation')
                .doc(),
            subjectAllocation,
          );
        }
      }

      subAllBatch.update(
        staffCollectionReference.doc(doc.id),
        {
          'subjects': staffSubjects,
        },
      );
    }

    await subAllBatch.commit();
  } catch (e) {
    rethrow;
  }
}

//* Student Information
//* -------------------------------------------------------------
Future<void> uploadToStudentInformation({
  required WriteBatch studentBatch,
  required String studentCollection,
  required List<Map<String, dynamic>> excelData,
  required String schoolId,
}) async {
  try {
    for (var data in excelData) {
      String birthDateString = data['Birth_Date'];

      Timestamp timestamp = timeStampComverter(birthDateString);

      DocumentReference<Map<String, dynamic>> studDocRef =
          firestore.collection(studentCollection).doc();

      studentBatch.set(
        studDocRef,
        {
          'fatherName': data['Father_Name'],
          'fatherNum': data['Contact_Number'],
          'grade': data['Grade'],
          'motherName': data['Mother_Name'],
          'motherNum': data['Mother_Contact'],
          'name': data['Full_Name'],
          'sID': studDocRef.id,
          'schoolID': schoolCollectionReference.doc(schoolId),
          'section': data['Section'],
          'DOB': timestamp,
          'aadharNum': data['Aadhar_Card'],
          'grNum': data['GR_Num'],
          'schoolStdID': data['Student_ID'],
          'caste': data['Caste'],
          'category': data['Category'],
          'religion': data['Religion'],
          'isDisable': data['Any_Disability'] == 'No' ? false : true,
          'gender': data['Gender'],
          'houseColor': data['House_Colour'],
          'bloodGrp': data['BG'],
          'address': data['Student_Address'],
        },
      );
    }
  } catch (e) {
    debugPrint('Error: $e');
    rethrow;
  }
}

//* Staff Information sheet
//* -------------------------------------------------------------
Future<void> uploadToStaffInformation({
  required WriteBatch staffBatch,
  required String staffCollection,
  required List<Map<String, dynamic>> excelData,
  required String schoolId,
}) async {
  try {
    for (var data in excelData) {
      Timestamp timestamp = timeStampComverter(data['dob']);

      List<String> roles = [];
      roles.add(data['staff_job_access']);

      DocumentReference<Map<String, dynamic>> staffDocRef =
          firestore.collection(staffCollection).doc();

      staffBatch.set(
        staffDocRef,
        {
          'name': data['staff_name'],
          'role': roles,
          'title': data['staff_job_title'],
          'DOB': timestamp,
          'phoneNum': data['phone_number'],
          'staffID': staffDocRef.id,
          'schoolID': schoolCollectionReference.doc(schoolId),
        },
      );
    }
  } catch (e) {
    debugPrint('Error: $e');
    rethrow;
  }
}

//* Classes Information sheet
//* -------------------------------------------------------------
Future<void> uploadToClassInformation({
  required WriteBatch classBatch,
  required String schoolCollection,
  required List<Map<String, dynamic>> excelData,
  required String schoolId,
}) async {
  try {
    List<Map<String, dynamic>> sectionsList = [];
    List<String> classesList = [];

    for (var data in excelData) {
      List<String> sections = [];
      for (int i = 1; i <= 2; i++) {
        String sectionName = data['section_name$i'];
        if (sectionName.isNotEmpty) {
          sections.add(sectionName);
        }
      }
      sectionsList.add({
        'grade': data['grade'],
        'sections': sections,
      });

      String grade = data['grade'];
      if (!classesList.contains(grade)) {
        classesList.add(grade);
      }
    }

    DocumentReference<Map<String, dynamic>> schoolDocRef =
        firestore.collection(schoolCollection).doc(schoolId);

    classBatch.update(
      schoolDocRef,
      {
        'sections': sectionsList,
        'classes': classesList,
      },
    );
  } catch (e) {
    debugPrint('Error: $e');
    rethrow;
  }
}

//* SchoolBasicInformation sheet
//* -------------------------------------------------------------
Future<String> uploadToSchoolBasicInformation({
  required WriteBatch schoolBatch,
  required String schoolCollection,
  required List<Map<String, dynamic>> excelData,
}) async {
  try {
    for (var data in excelData) {
      DocumentReference<Map<String, dynamic>> schoolDocRef =
          FirebaseFirestore.instance.collection(schoolCollection).doc();

      schoolBatch.set(
        schoolDocRef,
        {
          'udiseNumPrimarySchool': data['udiseNumPrimarySchool'],
          'udiseNumHighSchool': data['udiseNumHighSchool'],
          'name': data['school_name'],
          'feesInst': data['feesInst'].split(','),
          'address': {
            'streetName': data['streetName'],
            'city': data['city'],
            'district': data['district'],
            'pincode': data['pincode'],
            'state': data['state'],
            'country': data['country'],
          },
          'contactPerson': data['your_name'],
          'contactNum': data['your_phone_number'],
          'parentOrgName': data['parent_Org_Name'],
          'contactPersonRole': data['your_job_role'],
          'schoolID': '',
          'status': 'onboarded',
          'joinDate': Timestamp.now()
        },
      );
      schoolBatch.update(
        schoolDocRef,
        {
          'schoolID': schoolDocRef.id,
        },
      );
      return schoolDocRef.id;
    }
  } catch (e) {
    debugPrint('Error: $e');
    rethrow;
  }
  return '';
}

Timestamp timeStampComverter(String birthDateString) {
  if (birthDateString == '' || birthDateString == '-') {
    return Timestamp(0, 0);
  } else {
    DateTime birthDate =
        DateFormat('yyyy-MM-ddTHH:mm:ss.SSSZ').parse(birthDateString);

    return Timestamp.fromDate(birthDate);
  }
}

List<Map<String, dynamic>> traverseExcelData(Sheet sheet) {
  List<Map<String, dynamic>> jsonData = [];

  if (sheet.maxRows == 0) {
    return jsonData;
  }

  var headers =
      sheet.row(0).map((cell) => cell?.value?.toString().trim() ?? '').toList();

  for (var i = 1; i < sheet.maxRows; i++) {
    Map<String, dynamic> rowMap = {};
    if (sheet.rows[i]
        .every((cell) => cell?.value?.toString().trim().isEmpty ?? true)) {
      break;
    }

    for (var j = 0; j < sheet.maxColumns; j++) {
      var header = headers[j];
      var cellValue = sheet.row(i)[j]?.value?.toString().trim() ?? '';
      rowMap[header] = cellValue;
    }

    jsonData.add(rowMap);
  }

  return jsonData;
}
