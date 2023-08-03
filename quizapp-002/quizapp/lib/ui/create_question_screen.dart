import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:quizapp/model/appcolors.dart';
import 'package:quizapp/model/question.dart';
import 'package:quizapp/utils/utils.dart';
import 'package:quizapp/widgets/round_button_widget.dart';

class CreateQuestionScreen extends StatefulWidget {
  const CreateQuestionScreen({Key? key}) : super(key: key);

  @override
  _CreateQuestionScreenState createState() => _CreateQuestionScreenState();
}

class _CreateQuestionScreenState extends State<CreateQuestionScreen> {
  final _formKey = GlobalKey<FormState>();
  final titleController = TextEditingController();
  final descController = TextEditingController();
  late String questionId;
  late String _questionText;
  final List<String> _options = [];
  int? _correctOptionIndex; // Changed type to int?
  String userId = FirebaseAuth.instance.currentUser!.uid;
  bool loading = false;

  void _addOption() {
    setState(() {
      _options.add('');
    });
  }

  void _removeOption(int index) {
    setState(() {
      _options.removeAt(index);
      if (_correctOptionIndex == index) {
        _correctOptionIndex = null;
      } else if (_correctOptionIndex != null && _correctOptionIndex! > index) {
        _correctOptionIndex = _correctOptionIndex! - 1;
      }
    });
  }

  Widget _buildOptionField(int index) {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            style: const TextStyle(color: AppColors.profilebgcolor),
            onChanged: (value) {
              setState(() {
                _options[index] = value;
              });
            },
            validator: (value) {
              if (value!.isEmpty) {
                return 'Option cannot be empty';
              }
              return null;
            },
            decoration: InputDecoration(
              labelText: 'Option ${index + 1}',
              labelStyle: const TextStyle(color: AppColors.profilebgcolor),
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.remove),
          onPressed: () => _removeOption(index),
        ),
      ],
    );
  }

  Widget _buildOptions() {
    List<Widget> rows = [];

    for (int i = 0; i < _options.length; i += 2) {
      List<Widget> columns = [];

      for (int j = i; j < i + 2 && j < _options.length; j++) {
        columns.add(
          Expanded(
            child: _buildOptionField(j),
          ),
        );
      }

      rows.add(
        Row(
          children: columns,
        ),
      );
    }

    return Column(
      children: [
        ...rows,
        DropdownButtonFormField<int>(
          value: _correctOptionIndex,
          items: _options
              .asMap()
              .entries
              .map((entry) => DropdownMenuItem<int>(
                    value: entry.key,
                    child: Text('Option ${entry.key + 1}'),
                  ))
              .toList(),
          onChanged: (value) {
            setState(() {
              _correctOptionIndex = value;
            });
          },
          decoration: const InputDecoration(
            labelText: 'Correct Option',
          ),
        ),
        const SizedBox(height: 20),
        RoundButton(
          onTap: _addOption,
          title: 'Add Option',
          btncolor: AppColors.optionnotselectedcolor,
          btntxtcolor: AppColors.profilebgcolor,
        ),
      ],
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        loading = true;
      });
      final int index = _correctOptionIndex ??
          -1; // If _correctOptionIndex is null, assign -1

      final question = Question(
        questionId: questionId,
        userId: userId,
        title: titleController.text,
        description: descController.text,
        question: _questionText,
        options: _options,
        correctOptionIndex: index,
      );
      FirebaseFirestore.instance
          .collection('quiz')
          .add(question.toMap())
          .then((value) {
        // Question stored successfully
        questionId = value.id; // Fetch the generated questionId
        Utils().toastmessage('Question stored successfully');
        // Reset form and navigate to another screen
        _formKey.currentState!.reset();
      }).catchError((error) {
        // Error storing question
        Utils().toastmessage(error.toString());
      });
      setState(() {
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          automaticallyImplyLeading: false,
          leading: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(
                Icons.arrow_back,
                color: AppColors.optionnotselectedcolor,
              )),
          backgroundColor: AppColors.profilebgcolor,
          title: const Text(
            'Create Question',
            style: TextStyle(color: AppColors.optionnotselectedcolor),
          )),
      // backgroundColor: AppColors.bgcolor,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(children: [
            Column(
              children: [
                TextFormField(
                  controller: titleController,
                  style: const TextStyle(color: AppColors.profilebgcolor),
                  onTapOutside: (event) {
                    print('onTapOutside');
                    FocusManager.instance.primaryFocus?.unfocus();
                  },
                  onChanged: (value) {
                    setState(() {
                      _questionText = value;
                    });
                  },
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Title cannot be empty';
                    }
                    return null;
                  },
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    labelStyle: TextStyle(color: AppColors.profilebgcolor),
                  ),
                ),
                TextFormField(
                  controller: descController,
                  style: const TextStyle(color: AppColors.profilebgcolor),
                  onTapOutside: (event) {
                    print('onTapOutside');
                    FocusManager.instance.primaryFocus?.unfocus();
                  },
                  onChanged: (value) {
                    setState(() {
                      _questionText = value;
                    });
                  },
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Description cannot be empty';
                    }
                    return null;
                  },
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    labelStyle: TextStyle(color: AppColors.profilebgcolor),
                  ),
                ),
                TextFormField(
                  style: const TextStyle(color: AppColors.profilebgcolor),
                  onTapOutside: (event) {
                    print('onTapOutside');
                    FocusManager.instance.primaryFocus?.unfocus();
                  },
                  onChanged: (value) {
                    setState(() {
                      _questionText = value;
                    });
                  },
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Question cannot be empty';
                    }
                    return null;
                  },
                  decoration: const InputDecoration(
                    labelText: 'Question',
                    labelStyle: TextStyle(color: AppColors.profilebgcolor),
                  ),
                ),
                _buildOptions(),
                const SizedBox(height: 20),
                RoundButton(
                  onTap: _submitForm,
                  title: 'Submit',
                  loading: loading,
                  btncolor: AppColors.scorecolor,
                  btntxtcolor: AppColors.optionnotselectedcolor,
                ),
              ],
            ),
          ]),
        ),
      ),
    );
  }
}
