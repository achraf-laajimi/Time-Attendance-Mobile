import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final referenceController = TextEditingController();
  final descriptionController = TextEditingController();
  final categoryController = TextEditingController();
  final quantityController = TextEditingController();
  final priceController = TextEditingController();

  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;

  @override
  void dispose() {
    nameController.dispose();
    referenceController.dispose();
    descriptionController.dispose();
    categoryController.dispose();
    quantityController.dispose();
    priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const CloseButton(),
        actions: [
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              shadowColor: Colors.transparent,
            ),
            onPressed: _saveProduct,
            icon: const Icon(Icons.save),
            label: const Text('Save'),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildNameField(),
              const SizedBox(height: 12),
              _buildReferenceField(),
              const SizedBox(height: 12),
              _buildCategoryField(),
              const SizedBox(height: 12),
              _buildQuantityField(),
              const SizedBox(height: 12),
              _buildPriceField(),
              const SizedBox(height: 14),
              _buildDescriptionField(),
              const SizedBox(height: 12),
              _buildImageField(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNameField() => TextFormField(
        controller: nameController,
        decoration: const InputDecoration(
          labelText: 'Product Name',
          border: OutlineInputBorder(),
        ),
        validator: (value) => value!.isEmpty ? 'Name cannot be empty' : null,
      );

  Widget _buildReferenceField() => TextFormField(
        controller: referenceController,
        decoration: const InputDecoration(
          labelText: 'Reference (Unique)',
          border: OutlineInputBorder(),
        ),
        validator: (value) => value!.isEmpty ? 'Reference cannot be empty' : null,
      );

  Widget _buildCategoryField() => TextFormField(
        controller: categoryController,
        decoration: const InputDecoration(
          labelText: 'Category',
          border: OutlineInputBorder(),
        ),
        validator: (value) => value!.isEmpty ? 'Category cannot be empty' : null,
      );

  Widget _buildQuantityField() => TextFormField(
        controller: quantityController,
        decoration: const InputDecoration(
          labelText: 'Quantity',
          border: OutlineInputBorder(),
        ),
        keyboardType: TextInputType.number,
        validator: (value) {
          if (value!.isEmpty) return 'Quantity cannot be empty';
          if (int.tryParse(value) == null) return 'Enter a valid number';
          if (int.parse(value) < 0) return 'Quantity cannot be negative';
          return null;
        },
      );

  Widget _buildPriceField() => TextFormField(
        controller: priceController,
        decoration: const InputDecoration(
          labelText: 'Price',
          border: OutlineInputBorder(),
        ),
        keyboardType: TextInputType.numberWithOptions(decimal: true),
        validator: (value) {
          if (value!.isEmpty) return 'Price cannot be empty';
          if (double.tryParse(value) == null) return 'Enter a valid number';
          if (double.parse(value) < 0) return 'Price cannot be negative';
          return null;
        },
      );

  Widget _buildDescriptionField() => TextFormField(
        controller: descriptionController,
        maxLines: 4,
        decoration: const InputDecoration(
          labelText: 'Description',
          border: OutlineInputBorder(),
          alignLabelWithHint: true,
        ),
      );

  Widget _buildImageField() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        'Product Image',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 8),
      Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => _pickImage(ImageSource.gallery),
              icon: const Icon(Icons.photo_library),
              label: const Text('Gallery'),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => _pickImage(ImageSource.camera),
              icon: const Icon(Icons.camera_alt),
              label: const Text('Camera'),
            ),
          ),
        ],
      ),
      if (_selectedImage != null) ...[
        const SizedBox(height: 16),
        Container(
          height: 200,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            image: DecorationImage(
              image: FileImage(_selectedImage!),
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(height: 8),
        OutlinedButton(
          onPressed: () => setState(() => _selectedImage = null),
          child: const Text('Remove Image'),
        ),
      ],
      if (_isUploading) ...[
        const SizedBox(height: 8),
        const LinearProgressIndicator(),
        const SizedBox(height: 8),
        const Text('Uploading image...'),
      ],
    ],
  );

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1800,
        maxHeight: 1800,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: ${e.toString()}')),
      );
    }
  }

  Future<void> _saveProduct() async {
    /*if (_formKey.currentState!.validate()) {
      setState(() => _isUploading = true);
      
      try {
        String? imageUrl;
        if (_selectedImage != null) {
          // Upload image to your server/storage
          imageUrl = await _uploadImage(_selectedImage!);
        }

        final product = await Product.create({
          'name': nameController.text,
          'reference': referenceController.text,
          'description': descriptionController.text,
          'category': categoryController.text,
          'quantity': int.parse(quantityController.text),
          'price': double.parse(priceController.text),
          'image': imageUrl,
        });

        if (!mounted) return;
        Navigator.pop(context, product);
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      } finally {
        if (mounted) {
          setState(() => _isUploading = false);
        }
      }
    }*/
  }

  Future<String> _uploadImage(File image) async {
    // Implement your actual image upload logic here
    // This is just a simulation with 2 second delay
    await Future.delayed(const Duration(seconds: 2));
    return 'https://example.com/products/${DateTime.now().millisecondsSinceEpoch}.jpg';
    
    /* Example Firebase Storage implementation:
    final ref = FirebaseStorage.instance
        .ref()
        .child('product_images/${DateTime.now().millisecondsSinceEpoch}.jpg');
    
    final uploadTask = ref.putFile(image);
    final snapshot = await uploadTask.whenComplete(() {});
    return await snapshot.ref.getDownloadURL();
    */
  }

}