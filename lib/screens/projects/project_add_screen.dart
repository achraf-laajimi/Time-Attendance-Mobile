import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:in_out/screens/projects/models/project_model.dart';
import 'package:in_out/screens/projects/models/product_model.dart';
import 'package:in_out/screens/projects/services/project_service.dart';
import 'models/ExpressUser.dart';
import 'products_selection_screen.dart';
import 'services/product_service.dart';
import 'services/user_service.dart';


class ProjectAddScreen extends StatefulWidget {
  const ProjectAddScreen({super.key});

  @override
  State<ProjectAddScreen> createState() => _ProjectAddScreenState();
}

class _ProjectAddScreenState extends State<ProjectAddScreen> {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();
  final nameController = TextEditingController();
  final entrepriseController = TextEditingController();
  final descriptionController = TextEditingController();
  
  late DateTime beginDate;
  late DateTime endDate;
  ProjectStatus _selectedStatus = ProjectStatus.toDo;
  ExpressUser? selectedClient;
  ExpressUser? selectedProjectManager;
  ExpressUser? selectedStockManager;
  List<ExpressUser> availableClients = []; 
  List<ExpressUser> availableProjectManagers = [];
  List<ExpressUser> availableStockManagers = [];
  List<Product> availableProducts = [];
  Map<String, int> selectedProducts = {};
  bool isLoadingProducts = false;
  bool showProductsSection = false;

  @override
  void initState() {
    super.initState();
    beginDate = DateTime.now();
    endDate = DateTime.now().add(const Duration(days: 1));
    _loadAvailableUsers();
  }

  Future<void> _loadAvailableUsers() async {
    try {
      final clients = await ExpressUserService().getClients();
      final managers = await ExpressUserService().getManagers();
      final stockManagers = await ExpressUserService().getStockManagers();
      
      setState(() {
        availableClients = clients;
        availableProjectManagers = managers;
        availableStockManagers = stockManagers;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load users: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _loadAvailableProducts() async {
    if (selectedStockManager == null) return;

    setState(() => isLoadingProducts = true);
    try {
      final result = await ProductService().getProducts();
      if (result['success'] == true) {
        final products = <Product>[];
        
        for (var item in (result['data']['products'] as List)) {
          try {
            products.add(Product.fromDynamic(item));
          } catch (e) {
            print('Failed to parse product: $e');
          }
        }
        
        setState(() {
          availableProducts = products;
          isLoadingProducts = false;
          showProductsSection = true;
        });
      } else {
        setState(() => isLoadingProducts = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to load products: ${result['message']}')),
          );
        }
      }
    } catch (e) {
      setState(() => isLoadingProducts = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading products: ${e.toString()}')),
        );
      }
    }
  }

  void _handleStockManagerChange(ExpressUser? newValue) {
    setState(() {
      selectedStockManager = newValue;
      if (newValue != null) {
        _loadAvailableProducts();
      } else {
        showProductsSection = false;
        selectedProducts.clear();
      }
    });
  }


  @override
  void dispose() {
    nameController.dispose();
    entrepriseController.dispose();
    descriptionController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: const CloseButton(),
        title: const Text('New Project'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.primaryColor,
                foregroundColor: Colors.white,
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onPressed: _saveProject,
              icon: const Icon(Icons.add, size: 20, color: Colors.white,),
              label: const Text('Confirm'),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          controller: _scrollController,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader('Project Details'),
              _buildNameField(),
              const SizedBox(height: 16),
              
              _buildEntrepriseField(),
              const SizedBox(height: 16),
              
              _buildDateTimePickers(),
              const SizedBox(height: 16),
            
              _buildDescriptionField(),
              const SizedBox(height: 24),
              
              _buildSectionHeader('Team Assignment'),
              _buildClientDropdown(),
              const SizedBox(height: 16),
              
              _buildProjectManagerDropdown(),
              const SizedBox(height: 16),
              
              _buildStockManagerDropdown(),
              const SizedBox(height: 24),
              
              _buildSectionHeader('Project Status'),
              _buildStatusSelection(),
              const SizedBox(height: 24),
              
              if (showProductsSection) ...[
                      _buildSectionHeader('Product Allocation'),
                      _buildProductSelectionButton(),
                      if (selectedProducts.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Text(
                          'Total Products Selected: ${selectedProducts.length}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ],
              
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).primaryColor,
        ),
      ),
    );
  }

  Widget _buildNameField() {
    return TextFormField(
      controller: nameController,
      decoration: InputDecoration(
        labelText: 'Project Name',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        prefixIcon: const Icon(Icons.work_outline),
      ),
      validator: (value) => value!.isEmpty ? 'Name cannot be empty' : null,
      style: const TextStyle(fontSize: 16),
    );
  }

  Widget _buildEntrepriseField() {
    return TextFormField(
      controller: entrepriseController,
      decoration: InputDecoration(
        labelText: 'Entreprise',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        prefixIcon: const Icon(Icons.business_outlined),
      ),
      validator: (value) => value!.isEmpty ? 'Entreprise cannot be empty' : null,
      style: const TextStyle(fontSize: 16),
    );
  }

  Widget _buildDateTimePickers() {
    return Row(
      children: [
        Expanded(
          child: _buildDatePicker('Start Date', beginDate, (date) {
            setState(() => beginDate = date);
            if (endDate.isBefore(date)) {
              setState(() => endDate = date.add(const Duration(days: 1)));
            }
          }),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildDatePicker('End Date', endDate, (date) {
            if (date.isAfter(beginDate)) {
              setState(() => endDate = date);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('End date must be after start date')),
              );
            }
          },
        ),
    )],
    );
  }

  Widget _buildDatePicker(String label, DateTime date, ValueChanged<DateTime> onDateSelected) {
    return InkWell(
      onTap: () async {
        final selectedDate = await showDatePicker(
          context: context,
          initialDate: date,
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 365)),
        );
        if (selectedDate != null) {
          onDateSelected(selectedDate);
        }
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          prefixIcon: const Icon(Icons.calendar_today),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(DateFormat.yMMMd().format(date)),
            const Icon(Icons.arrow_drop_down),
          ],
        ),
      ),
    );
  }

  Widget _buildDescriptionField() {
    return TextFormField(
      controller: descriptionController,
      maxLines: 4,
      decoration: InputDecoration(
        labelText: 'Description',
        alignLabelWithHint: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      validator: (value) => value!.isEmpty ? 'Please enter a description' : null,
      style: const TextStyle(fontSize: 16),
    );
  }

  Widget _buildClientDropdown() {
    return DropdownButtonFormField<ExpressUser>(
      value: selectedClient,
      decoration: InputDecoration(
        labelText: 'Client',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        prefixIcon: const Icon(Icons.person_outline),
      ),
      items: availableClients.map((client) {
        return DropdownMenuItem<ExpressUser>(
          value: client,
          child: Text(client.name),
        );
      }).toList(),
      onChanged: (ExpressUser? newValue) {
        setState(() {
          selectedClient = newValue;
        });
      },
      validator: (value) => value == null ? 'Please select a client' : null,
    );
  }

  Widget _buildProjectManagerDropdown() {
    return DropdownButtonFormField<ExpressUser>(
      value: selectedProjectManager,
      decoration: InputDecoration(
        labelText: 'Project Manager',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        prefixIcon: const Icon(Icons.engineering_outlined),
      ),
      items: availableProjectManagers.map((manager) {
        return DropdownMenuItem<ExpressUser>(
          value: manager,
          child: Text(manager.name),
        );
      }).toList(),
      onChanged: (ExpressUser? newValue) {
        setState(() {
          selectedProjectManager = newValue;
        });
      },
      validator: (value) => value == null ? 'Please select a project manager' : null,
    );
  }

  Widget _buildStockManagerDropdown() {
    return DropdownButtonFormField<ExpressUser>(
      value: selectedStockManager,
      decoration: InputDecoration(
        labelText: 'Stock Manager (optional)',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        prefixIcon: const Icon(Icons.inventory_2_outlined),
      ),
      items: availableStockManagers.map((manager) {
        return DropdownMenuItem<ExpressUser>(
          value: manager,
          child: Text(manager.name),
        );
      }).toList(),
      onChanged: _handleStockManagerChange,
    );
  }

  Widget _buildStatusSelection() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: ProjectStatus.values.map((status) {
        return ChoiceChip(
          label: Text(status.toString()),
          selected: _selectedStatus == status,
          onSelected: (bool selected) {
            setState(() {
              _selectedStatus = status;
            });
          },
          selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
          labelStyle: TextStyle(
            color: _selectedStatus == status
                ? Theme.of(context).primaryColor
                : Theme.of(context).textTheme.bodyLarge?.color,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(
              color: _selectedStatus == status
                  ? Theme.of(context).primaryColor
                  : Theme.of(context).dividerColor,
            ),
          ),
        );
      }).toList(),
    );
  }

   Widget _buildProductSelectionButton() {
    return ElevatedButton.icon(
      onPressed: isLoadingProducts
          ? null
          : () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProductSelectionScreen(
                    initialSelections: selectedProducts,
                    projectId: null,
                  ),
                ),
              );
              if (result != null && result is Map<String, int>) {
                setState(() => selectedProducts = result);
              }
            },
      icon: const Icon(Icons.add),
      label: const Text('Manage Products'),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }


  void _saveProject() async {
    if (_formKey.currentState!.validate() && 
        selectedClient != null && 
        selectedProjectManager != null) {
      
      final messenger = ScaffoldMessenger.of(context);
      const loadingSnackBar = SnackBar(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 16),
            Text('Creating project...'),
          ],
        ),
        duration: Duration(seconds: 10),
      );
      
      messenger.showSnackBar(loadingSnackBar);

      try {
        // Convert selected products to proper format
        final productAllocations = selectedProducts.entries
            .map((entry) => {
                  'product': entry.key,
                  'quantity': entry.value,
                })
            .toList();

        // Create project JSON
        final projectJson = {
          'name': nameController.text,
          'entreprise': entrepriseController.text,
          'description': descriptionController.text,
          'beginDate': beginDate.toIso8601String(),
          'endDate': endDate.toIso8601String(),
          'status': _selectedStatus.value,
          'client': selectedClient!.id,
          'projectManager': selectedProjectManager!.id,
          if (selectedStockManager != null) 'stockManager': selectedStockManager!.id,
          'products': productAllocations,
        };

        final result = await ProjectService().createProject(projectJson);

        messenger.hideCurrentSnackBar();

        if (result['success'] == true) {
          // Success case
          if (mounted) {
            final createdProject = Project.fromJson(result['data']);
            Navigator.pop(context, createdProject);
          }
        } else {
          // Backend returned success: false
          if (mounted) {
            messenger.showSnackBar(
              SnackBar(
                content: Text('Failed: ${result['message'] ?? 'Unknown error'}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } catch (e) {
        messenger.hideCurrentSnackBar();
        if (mounted) {
          messenger.showSnackBar(
            SnackBar(
              content: Text('Error: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final context = _formKey.currentContext;
        if (context != null) {
          Scrollable.ensureVisible(context,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut);
        }
      });
    }
  }
}