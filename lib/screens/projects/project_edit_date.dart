import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:in_out/screens/projects/models/project_model.dart';
import 'package:in_out/screens/projects/services/project_service.dart';
import 'models/ExpressUser.dart';
import 'products_selection_screen.dart';
import 'services/user_service.dart';

class ProjectEditScreen extends StatefulWidget {
  final Project project;
  const ProjectEditScreen({super.key, required this.project});

  @override
  State<ProjectEditScreen> createState() => _ProjectEditScreenState();
}

class _ProjectEditScreenState extends State<ProjectEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();
  late TextEditingController nameController;
  late TextEditingController entrepriseController;
  late TextEditingController descriptionController;
  late DateTime beginDate;
  late DateTime endDate;
  late ProjectStatus _selectedStatus;
  ExpressUser? selectedClient;
  ExpressUser? selectedProjectManager;
  ExpressUser? selectedStockManager;
  List<ExpressUser> availableClients = [];
  List<ExpressUser> availableProjectManagers = [];
  List<ExpressUser> availableStockManagers = [];
  Map<String, int> selectedProducts = {};
  bool isLoading = false;
  bool showProductsSection = false;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.project.name);
    entrepriseController = TextEditingController(text: widget.project.entreprise);
    descriptionController = TextEditingController(text: widget.project.description ?? '');
    beginDate = widget.project.beginDate;
    endDate = widget.project.endDate;
    _selectedStatus = widget.project.status;
    selectedClient = widget.project.client;
    selectedProjectManager = widget.project.projectManager;
    selectedStockManager = widget.project.stockManager;
    selectedProducts = {
      for (var allocation in widget.project.products)
        allocation.product.id: allocation.allocatedQuantity
    };
    showProductsSection = widget.project.stockManager != null;
    _loadAvailableUsers();
  }

  Future<void> _loadAvailableUsers() async {
    try {
      final clients = await ExpressUserService().getClients();
      final managers = await ExpressUserService().getManagers();
      final stockManagers = await ExpressUserService().getStockManagers();

      // Remove duplicates by ID
      final uniqueClients = clients.fold<Map<String, ExpressUser>>(
        {},
        (map, user) => map..putIfAbsent(user.id, () => user),
      ).values.toList();

      final uniqueManagers = managers.fold<Map<String, ExpressUser>>(
        {},
        (map, user) => map..putIfAbsent(user.id, () => user),
      ).values.toList();

      final uniqueStockManagers = stockManagers.fold<Map<String, ExpressUser>>(
        {},
        (map, user) => map..putIfAbsent(user.id, () => user),
      ).values.toList();

      setState(() {
        availableClients = uniqueClients;
        availableProjectManagers = uniqueManagers;
        availableStockManagers = uniqueStockManagers;

        selectedClient = uniqueClients.firstWhere(
          (c) => c.id == widget.project.client.id,
          orElse: () => uniqueClients.isNotEmpty ? uniqueClients.first : widget.project.client,
        );

        selectedProjectManager = uniqueManagers.firstWhere(
          (m) => m.id == widget.project.projectManager.id,
          orElse: () => uniqueManagers.isNotEmpty ? uniqueManagers.first : widget.project.projectManager,
        );

        if (widget.project.stockManager != null) {
          selectedStockManager = uniqueStockManagers.firstWhere(
            (s) => s.id == widget.project.stockManager!.id,
            orElse: () => uniqueStockManagers.isNotEmpty ? uniqueStockManagers.first : widget.project.stockManager!,
          );
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load users: $e')),
        );
      }
    }
  }

  void _handleStockManagerChange(ExpressUser? newValue) {
    setState(() {
      selectedStockManager = newValue;
      showProductsSection = newValue != null;
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

  Future<void> _saveProject() async {
    if (_formKey.currentState!.validate() &&
        selectedClient != null &&
        selectedProjectManager != null) {
      setState(() => isLoading = true);
      final messenger = ScaffoldMessenger.of(context);

      try {
        final updatedProjectData = {
          'name': nameController.text,
          'entreprise': entrepriseController.text,
          'description': descriptionController.text.isNotEmpty
              ? descriptionController.text
              : null,
          'beginDate': beginDate.toIso8601String(),
          'endDate': endDate.toIso8601String(),
          'status': _selectedStatus.value,
          'client': selectedClient!.id,
          'projectManager': selectedProjectManager!.id,
          'stockManager': selectedStockManager?.id,
          'products': selectedStockManager != null
              ? selectedProducts.entries
                  .where((entry) => entry.value > 0)
                  .map((entry) => {'product': entry.key, 'quantity': entry.value})
                  .toList()
              : [],
        };

        final result = await ProjectService().updateProject(
          widget.project.id,
          updatedProjectData,
        );

        setState(() => isLoading = false);

        if (result['success'] == true) {
          final updatedProject = Project.fromJson(result['data']);
          messenger.showSnackBar(
            const SnackBar(
              content: Text('Project updated successfully!'),
              duration: Duration(seconds: 2),
            ),
          );
          await Future.delayed(const Duration(milliseconds: 1500));
          if (mounted) Navigator.pop(context, updatedProject);
        } else {
          messenger.showSnackBar(
            SnackBar(
              content: Text('Failed: ${result['message'] ?? 'Unknown error'}'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      } catch (e) {
        setState(() => isLoading = false);
        messenger.showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all required fields'),
          duration: Duration(seconds: 2),
        ),
      );
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final context = _formKey.currentContext;
        if (context != null) {
          Scrollable.ensureVisible(context,
              duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: const CloseButton(),
        title: const Text('Edit Project'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.primaryColor,
                foregroundColor: Colors.white,
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onPressed: isLoading ? null : _saveProject,
              icon: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : const Icon(Icons.save, size: 20, color: Colors.white),
              label: Text(isLoading ? 'Saving...' : 'Save'),
            ),
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
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
          }),
        ),
      ],
    );
  }

  Widget _buildDatePicker(String label, DateTime date, ValueChanged<DateTime> onDateSelected) {
    return InkWell(
      onTap: () async {
        final selectedDate = await showDatePicker(
          context: context,
          initialDate: date,
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
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
      value: availableClients.contains(selectedClient) ? selectedClient : null,
      decoration: InputDecoration(
        labelText: 'Client',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        prefixIcon: const Icon(Icons.person_outline),
      ),
      items: availableClients.map((client) {
        return DropdownMenuItem<ExpressUser>(
          value: client,
          child: Text(client.name),
        );
      }).toList(),
      onChanged: (ExpressUser? newValue) {
        setState(() => selectedClient = newValue);
      },
      validator: (value) => value == null ? 'Please select a client' : null,
    );
  }

  Widget _buildProjectManagerDropdown() {
    return DropdownButtonFormField<ExpressUser>(
      value: availableProjectManagers.contains(selectedProjectManager) 
          ? selectedProjectManager 
          : null,
      decoration: InputDecoration(
        labelText: 'Project Manager',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        prefixIcon: const Icon(Icons.engineering_outlined),
      ),
      items: availableProjectManagers.map((manager) {
        return DropdownMenuItem<ExpressUser>(
          value: manager,
          child: Text(manager.name),
        );
      }).toList(),
      onChanged: (ExpressUser? newValue) {
        setState(() => selectedProjectManager = newValue);
      },
      validator: (value) => value == null ? 'Please select a project manager' : null,
    );
  }

  Widget _buildStockManagerDropdown() {
    return DropdownButtonFormField<ExpressUser>(
      value: selectedStockManager != null && availableStockManagers.contains(selectedStockManager)
          ? selectedStockManager
          : null,
      decoration: InputDecoration(
        labelText: 'Stock Manager (optional)',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        prefixIcon: const Icon(Icons.inventory_2_outlined),
      ),
      items: [
        const DropdownMenuItem<ExpressUser>(
          value: null,
          child: Text('None'),
        ),
        ...availableStockManagers.map((manager) {
          return DropdownMenuItem<ExpressUser>(
            value: manager,
            child: Text(manager.name),
          );
        }),
      ],
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
            setState(() => _selectedStatus = status);
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
      onPressed: isLoading
          ? null
          : () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProductSelectionScreen(
                    initialSelections: selectedProducts,
                    projectId: widget.project.id,
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
}