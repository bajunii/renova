import 'dart:io';
import 'package:flutter/material.dart';
import '../../../core/colors/colors.dart';
import 'package:image_picker/image_picker.dart';

class EventForm extends StatefulWidget {
  const EventForm({super.key});

  @override
  State<EventForm> createState() => _EventFormState();
}

class _EventFormState extends State<EventForm> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _venueController = TextEditingController();
  final _descriptionController = TextEditingController();

  File? _imageFile;
  bool _isLoading = false;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  DateTime? _selectedDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      setState(() => _isLoading = true);

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error saving event: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _venueController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text(
            "Add New event",
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: AppColors.background,
          elevation: 2,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(labelText: 'Event Title'),
                  validator: (value) =>
                      value!.isEmpty ? 'Title is required' : null,
                ),
                SizedBox(height: 4.0),

                // Venue
                TextFormField(
                  controller: _venueController,
                  decoration: const InputDecoration(labelText: 'Event Venue'),
                  validator: (value) =>
                      value!.isEmpty ? 'Venue is required' : null,
                ),
                SizedBox(height: 4.0),
                // Example Date Picker Section
                Text(
                  'Event Date',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 4.0),

                // Event Date
                ElevatedButton(
                  onPressed: () async {
                    final pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2035),
                    );
                    if (pickedDate != null) {
                      setState(() {
                        _selectedDate = pickedDate;
                      });
                    }
                  },
                  child: Text(
                    _selectedDate == null
                        ? 'Select Date'
                        : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                  ),
                ),

                // Start Time Picker
                const SizedBox(height: 12.0),
                Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Start Time',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),

                        const SizedBox(height: 4.0),
                        ElevatedButton(
                          onPressed: () async {
                            final pickedTime = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.now(),
                            );
                            if (pickedTime != null) {
                              setState(() {
                                _startTime = pickedTime;
                              });
                            }
                          },
                          child: Text(
                            _startTime == null
                                ? 'Select Start Time'
                                : _startTime!.format(context),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 16),

                    // End Time Picker
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'End Time',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),

                        const SizedBox(height: 4),
                        ElevatedButton(
                          onPressed: () async {
                            final pickedTime = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.now(),
                            );
                            if (pickedTime != null) {
                              setState(() {
                                _endTime = pickedTime;
                              });
                            }
                          },
                          child: Text(
                            _endTime == null
                                ? 'Select End Time'
                                : _endTime!.format(context),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                // Event Description
                const SizedBox(height: 4.0),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Event Description',
                  ),
                  maxLines: 4,
                  validator: (value) =>
                      value!.isEmpty ? 'Description is required' : null,
                ),

                const SizedBox(height: 16.0),

                // Image URL
                Card(
                  elevation: 4.0,
                  margin: const EdgeInsets.only(bottom: 20.0),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        _imageFile == null
                            ? Container(
                                height: 150,
                                width: double.infinity,
                                color: Colors.grey[200],
                                child: const Center(
                                  child: Text('No image selected'),
                                ),
                              )
                            : Image.file(
                                _imageFile!,
                                height: 150,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                        const SizedBox(height: 16.0),
                        ElevatedButton.icon(
                          onPressed: _pickImage,
                          icon: const Icon(Icons.photo_library),
                          label: const Text('Select Image'),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),
                // Submit Button
                SizedBox(
                  width: double.infinity,
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : ElevatedButton(
                          onPressed: _submitForm,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),

                          child: const Text(
                            'Save Event',
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
