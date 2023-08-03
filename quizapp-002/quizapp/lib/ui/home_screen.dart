import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:quizapp/model/appcolors.dart';
import 'package:quizapp/model/question.dart';
import 'package:quizapp/ui/create_question_screen.dart';
import 'package:quizapp/ui/edit_question_screen.dart';
import 'package:quizapp/ui/login_screen.dart';
import 'package:quizapp/ui/splash_screen.dart';
import 'package:quizapp/utils/utils.dart';

class HomeScreen extends StatefulWidget {
  final User user;
  const HomeScreen({super.key, required this.user});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Question> questions = [];
  late List<int?> _selectedOptions;
  bool loading = false;
  Future<void> signOutAndNavigateToLogin() async {
    await auth.signOut().catchError((error) {
      print(error.toString());
    });
    await GoogleSignIn().signOut();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SplashScreen()),
    );
  }

  @override
  void initState() {
    super.initState();
    _selectedOptions = List<int?>.filled(questions.length,
        null); // Initialize _selectedOptions with the same length as questions
  }

  void updateSelectedOption(int questionIndex, int optionIndex) async {
    final collection = FirebaseFirestore.instance.collection('quiz');

    final docSnapshot = await collection.doc(questionIndex.toString()).get();

    if (docSnapshot.exists) {
      final selectedOptionData = {
        'selectedOptionIndex': optionIndex,
      };

      await docSnapshot.reference.update(selectedOptionData);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.profilebgcolor,
        leading: IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const CreateQuestionScreen()),
              );
            },
            icon: const Icon(
              Icons.menu,
              color: AppColors.optionnotselectedcolor,
            )),
        title: const Text(
          'Quiz App',
          style: TextStyle(
              color: AppColors.optionnotselectedcolor,
              fontSize: 30,
              fontWeight: FontWeight.bold),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10.0),
            child: InkWell(
              onTap: () {
                signOutAndNavigateToLogin();
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const LoginScreen()));
              },
              child: const CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.optionnotselectedcolor,
                child: Icon(
                  Icons.person,
                  size: 30,
                  color: AppColors.profilebgcolor,
                ),
              ),
            ),
          )
        ],
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('quiz').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          List<Question> questions = snapshot.data!.docs.map((doc) {
            Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
            return Question(
              questionId: data['questionId'] ?? '',
              userId: data['userId'],
              title: data['title'],
              description: data['description'],
              question: data['question'],
              options: List<String>.from(data['options']),
              correctOptionIndex: data['correctOptionIndex'],
            );
          }).toList();
          if (_selectedOptions.length != questions.length) {
            // Update _selectedOptions length if it doesn't match questions length
            _selectedOptions = List<int?>.filled(questions.length, null);
          }
          return ListView.builder(
            itemCount: questions.length,
            itemBuilder: (context, index) {
              Question question = questions[index];
              return Dismissible(
                key: Key(question.hashCode
                    .toString()), // Use question's hashCode as the key
                onDismissed: (direction) {
                  deleteQuestion(
                      question,
                      snapshot.data!.docs[index]
                          .id); // Pass the question and document ID to deleteQuestion
                },
                child: Padding(
                  padding:
                      const EdgeInsets.only(left: 10.0, right: 10, top: 20),
                  child: Card(
                    child: Padding(
                      padding:
                          const EdgeInsets.only(left: 10.0, right: 10, top: 10),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Title: ${question.title}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18)),
                              IconButton(
                                  onPressed: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                EditQuestionScreen(
                                                  question: questions[index],
                                                  questionId: snapshot
                                                      .data!.docs[index].id,
                                                )));
                                  },
                                  icon: const Icon(Icons.edit_note))
                            ],
                          ),
                          Text(
                            'Description: ${question.description}',
                            style: const TextStyle(fontSize: 14),
                          ),
                          ListTile(
                            title: Text(question.question),
                            subtitle: Column(
                              children: List.generate(
                                question.options.length,
                                (optionIndex) => RadioListTile<int>(
                                  title: Text(
                                    question.options[optionIndex],
                                    style: const TextStyle(
                                      color: AppColors.profilebgcolor,
                                    ),
                                  ),
                                  value: optionIndex,
                                  groupValue: _selectedOptions[index],
                                  onChanged: (int? value) {
                                    setState(() {
                                      _selectedOptions[index] = value ??
                                          0; // Assign 0 if value is null
                                      updateSelectedOption(index, value ?? 0);
                                    });
                                  },
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> deleteQuestion(Question question, String documentId) async {
    final collection = FirebaseFirestore.instance.collection('quiz');

    await collection.doc(documentId).delete().then((value) {
      Utils().toastmessage('Question Deleted');
    }).onError((error, stackTrace) {
      Utils().toastmessage(error.toString());
    });

    setState(() {
      questions.remove(question);
    });
  }
}
