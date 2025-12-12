import 'package:flutter/material.dart';
import 'package:in_out/screens/projects/services/project_service.dart';
import 'package:in_out/theme/adaptive_colors.dart';
import 'models/product_model.dart';
import 'models/project_model.dart';
import 'models/task_model.dart';
import 'products_selection_screen.dart';
import 'project_edit_date.dart';
import 'services/product_service.dart';
import 'services/task_service.dart';
import 'task_add_screen.dart';
import 'task_edit_screen.dart';
import 'task_details_screen.dart';
import '../../localization/app_localizations.dart';

class ProjectTasksScreen extends StatefulWidget {
  final Project project;

  const ProjectTasksScreen({super.key, required this.project});

  @override
  State<ProjectTasksScreen> createState() => _ProjectTasksScreenState();
}

class _ProjectTasksScreenState extends State<ProjectTasksScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();
  late Project _project;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _project = widget.project.copyWith(); 
    _tabController = TabController(length: 3, vsync: this);
    _scrollController.addListener(_scrollListener);
    _refreshProject();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _refreshProject() async {
    setState(() => _isLoading = true);
    final result = await ProjectService().getProjectById(_project.id);
    if (result['success'] == true) {
      setState(() {
        _project = Project.fromJson(result['data']).copyWith(); // Force new instance
        _isLoading = false;
      });
    } else {
      
    }
  }

  void _scrollListener() {
    setState(() {
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // Project Header
          SliverAppBar(
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: AdaptiveColors.primaryTextColor(context),
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
            expandedHeight: 150,
            floating: false,
            pinned: true,
            backgroundColor: AdaptiveColors.cardColor(context),
            flexibleSpace: FlexibleSpaceBar(
              background: _buildProjectHeader(context),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                onPressed: () async {
                  final updatedProject = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProjectEditScreen(project: _project),
                    ),
                  );
                  
                  if (updatedProject != null && updatedProject is Project) {
                    setState(() {
                      _project = updatedProject;
                    });
                    
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Project updated successfully')),
                    );
                  }
                },
                tooltip: 'Edit Project',
              ),
            ],
          ),

          // Tab Bar
          SliverPersistentHeader(
            pinned: true,
            delegate: _TabBarDelegate(
              TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(icon: Icon(Icons.task_outlined), text: 'Tasks'),
                  Tab(icon: Icon(Icons.inventory_2_outlined), text: 'Products'),
                  Tab(icon: Icon(Icons.info_outline), text: 'Info'),
                ],
                labelColor: AdaptiveColors.primaryGreen,
                unselectedLabelColor: AdaptiveColors.secondaryTextColor(context),
                indicatorColor: AdaptiveColors.primaryGreen,
                indicatorWeight: 3,
              ),
            ),
          ),

          // Tab Content
          SliverFillRemaining(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildTasksTab(),
                _buildProductsTab(),
                _buildInfoTab(),
              ],
            ),
          ),
        ],
      ),
      
    );
  }

  Widget _buildProjectHeader(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;
    
    // Responsive sizing
    final isTablet = screenWidth > 600;
    final titleFontSize = isTablet ? screenWidth * 0.045 : screenWidth * 0.055;
    final containerPadding = screenWidth * 0.05;
    
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AdaptiveColors.getPrimaryColor(context),
            AdaptiveColors.getPrimaryColor(context).withOpacity(0.8),
          ],
          stops: const [0.0, 1.0],
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(containerPadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: screenHeight * 0.01), // Reduced from 0.05 to 0.01
            // Project Name
            Text(
                  _project.name,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: titleFontSize,
                    letterSpacing: 1.2,
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.3),
                        offset: const Offset(0, 2),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                
                SizedBox(height: screenHeight * 0.015), 

                // Clean info row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Tasks info
                    Column(
                      children: [
                        Text(
                          '${_project.tasks.where((t) => t.status == TaskStatus.Completed).length}/${_project.tasks.length}',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: screenWidth * 0.045,
                          ),
                        ),
                        Text(
                          'Tasks Done',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: screenWidth * 0.032,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    
                    // Vertical divider
                    Container(
                      height: screenHeight * 0.04,
                      width: 1,
                      color: Colors.white.withOpacity(0.3),
                    ),
                    
                    // Deadline info
                    Column(
                      children: [
                        Text(
                          _formatDate(_project.endDate),
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: screenWidth * 0.045,
                          ),
                        ),
                        Text(
                          'Deadline',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: screenWidth * 0.032,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: screenHeight * 0.01), // Reduced from 0.02 to 0.01
              ],
            ),
          ),
    );
  }

  Widget _buildTasksTab() {
    final tasks = _project.tasks;

    Future<void> _deleteTask(BuildContext context, Task task) async {
      try {
        final result = await TaskService().deleteTask(task.id);
        if (result["success"]) {
          setState(() {
            tasks.removeWhere((t) => t.id == task.id); 
          });
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(AppLocalizations.of(context).getString('taskDeletedSuccessfully')),
                backgroundColor: Colors.green,
              ),
            );
          }
        } else {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: ${result["message"]}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: SizedBox(
            width: double.infinity,  
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TaskAddScreen(projectId: _project.id),
                  ),
                ).then((createdTask) {
                  if (createdTask != null && createdTask is Task) {
                    setState(() {
                      _project.tasks.add(createdTask);
                    });
                    // ignore: use_build_context_synchronously
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Task created successfully')),
                    );
                  }
                });
              },
              icon: const Icon(Icons.add),
              label: const Text('Add Task'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ),

        // Task list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final task = tasks[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: Container(
                    width: 8,
                    decoration: BoxDecoration(
                      color: _getStatusColor(task.status),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  title: Text(
                    task.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(task.description),
                      const SizedBox(height: 10),
                      Text(
                        '${_formatDate(task.beginDate)} - ${_formatDate(task.endDate)}',
                        style: TextStyle(
                          color: Theme.of(context).textTheme.bodySmall?.color,
                          fontSize: 12,
                        ),
                      ),
                      Chip(
                          label: Text(
                            task.status.toString().split('.').last,
                            style: TextStyle(
                              color: _getStatusColor(task.status),
                              fontSize: 12,
                            ),
                          ),
                          // ignore: deprecated_member_use
                          backgroundColor: _getStatusColor(task.status).withOpacity(0.1),
                      ),
                    ]
                  ),
                  trailing: PopupMenuButton<String>(
                    icon: Icon(
                      Icons.more_vert,
                      size: 24,
                      color: Theme.of(context).textTheme.bodySmall?.color,
                    ),
                    padding: EdgeInsets.zero,
                    itemBuilder: (BuildContext context) => [
                      const PopupMenuItem<String>(
                        value: 'view',
                        child: Row(
                          children: [
                            Icon(Icons.visibility_outlined, size: 20),
                            SizedBox(width: 8),
                            Text('View Details'),
                          ],
                        ),
                      ),
                      const PopupMenuItem<String>(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, size: 20, color: Colors.blue),
                            SizedBox(width: 8),
                            Text('Edit Task'),
                          ],
                        ),
                      ),
                      const PopupMenuItem<String>(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete_outline, size: 20, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Delete Task'),
                          ],
                        ),
                      ),
                    ],
                    onSelected: (String value) {
                      if (value == 'view') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TaskDetailsScreen(task: task),
                          ),
                        ).then((result) {
                          if (result != null && result is Task) {
                            setState(() {
                              final index = tasks.indexWhere((t) => t.id == result.id);
                              if (index != -1) {
                                tasks[index] = result; 
                              }
                            });
                          }
                        });
                      } else if (value == 'edit') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TaskEditScreen(task: task),
                          ),
                        ).then((updatedTask) {
                          if (updatedTask != null && updatedTask is Task) {
                            setState(() {
                              final index = tasks.indexWhere((t) => t.id == updatedTask.id);
                              if (index != -1) {
                                tasks[index] = updatedTask;
                              }
                            });
                          }
                        });
                      } else if (value == 'delete') {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) => AlertDialog(
                            title: const Text('Delete Task?'),
                            content: Text('Are you sure you want to delete "${task.name}"?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () {
                                  _deleteTask(context, task);
                                  Navigator.pop(context);
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Task deleted successfully'),
                                        backgroundColor: Colors.green,
                                      ),
                                    );
                                  }
                                },
                                child: const Text('Delete', style: TextStyle(color: Colors.red)),
                              ),
                            ],
                          ),
                        );
                      }}
                ),
              ));
            },
          ),
        ),
      ],
    );
  }

  Widget _buildProductsTab() {
    var productAllocations = _project.products;

    Future<void> _removeProduct(ProductAllocation allocation) async {
      if (allocation.product.id.isEmpty || allocation.product.name.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cannot remove invalid product'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      try {
        final updatedProducts = _project.products
            .where((a) => a.product.id != allocation.product.id)
            .map((a) => {'product': a.product.id, 'quantity': a.allocatedQuantity})
            .toList();

        final updatedProjectData = {
          'products': updatedProducts,
        };

        final result = await ProjectService().updateProject(_project.id, updatedProjectData);
        if (result['success'] == true) {
          if (mounted) {
            setState(() {
            productAllocations.remove(allocation); 
          });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Product allocation removed successfully'),
                backgroundColor: Colors.green,
              ),
            );
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(result['message'] ?? 'Failed to remove product allocation'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error removing product allocation: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }

    Future<List<ProductAllocation>> convertToProductAllocations(Map<String, int> selections) async {
      // First fetch all products to get complete product data
      final productsResult = await ProductService().getProducts();
      if (productsResult['success'] != true) {
        throw Exception('Failed to fetch products');
      }

      final allProducts = (productsResult['data']['products'] as List)
          .map((item) => Product.fromJson(item as Map<String, dynamic>))
          .toList();

      return selections.entries.map((entry) {
        final product = allProducts.firstWhere(
          (p) => p.id == entry.key,
        );

        return ProductAllocation(
          product: product,
          allocatedQuantity: entry.value,
        );
      }).toList();
    }

    void _manageProducts() async {
      final currentProducts = {
        for (var allocation in _project.products)
          allocation.product.id: allocation.allocatedQuantity
      };
      
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProductSelectionScreen(
            initialSelections: currentProducts,
            projectId: _project.id,
          ),
        ),
      );

      if (result != null && result is Map<String, int>) {
        try {
          setState(() => _isLoading = true);
          
          // Validate all product IDs before sending to backend
          final validProducts = result.entries.where((entry) {
            if (!RegExp(r'^[0-9a-fA-F]{24}$').hasMatch(entry.key)) {
              debugPrint('Invalid product ID skipped: ${entry.key}');
              return false;
            }
            return entry.value > 0;
          });

          final updatedProductsForBackend = validProducts.map((entry) => {
            'product': entry.key, 
            'quantity': entry.value
          }).toList();

          final updateResult = await ProjectService().updateProject(
            _project.id,
            {'products': updatedProductsForBackend},
          );

          if (updateResult['success'] == true) {
            await _refreshProject();
            // Convert to ProductAllocation list for local state
            final updatedAllocations = await convertToProductAllocations(result);
            
            setState(() {
              productAllocations = updatedAllocations;
            });

            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Products updated successfully')),
              );
            }
          } else {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Failed: ${updateResult['message'] ?? 'Unknown error'}'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: $e'),
                backgroundColor: Colors.red,
              ),
            );
          }
        } finally {
          if (mounted) {
            setState(() => _isLoading = false);
          }
        }
      }
    }

    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 24),
          /*child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _manageProducts,
              icon: const Icon(Icons.add),
              label: const Text('Manage Products'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),*/
        ),
        if (productAllocations.isEmpty)
          Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              children: [
                Icon(
                  Icons.inventory_2_outlined,
                  size: 64,
                  color: Theme.of(context).disabledColor,
                ),
                const SizedBox(height: 16),
                Text(
                  'No products allocated to this project',
                  style: TextStyle(
                    color: Theme.of(context).disabledColor,
                  ),
                ),
              ],
            ),
          ),
        if (productAllocations.isNotEmpty)
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: productAllocations.length,
              itemBuilder: (context, index) {
                final allocation = productAllocations[index];
                final product = allocation.product;
                if (product.id.isEmpty || product.name.isEmpty) {
                  return const ListTile(
                    title: Text('Invalid Product'),
                    subtitle: Text('Error: Product data is incomplete'),
                  );
                }

                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: Text(
                                  product.name.isNotEmpty ? product.name.substring(0, 1) : '?',
                                  style: TextStyle(
                                    color: Theme.of(context).primaryColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Text(
                                    'Ref: ${product.reference.isNotEmpty ? product.reference : 'N/A'}',
                                    style: TextStyle(
                                      color: Theme.of(context).textTheme.bodySmall?.color,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.remove_circle_outline,
                                color: Colors.red,
                              ),
                              onPressed: () => _removeProduct(allocation),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Allocated'),
                                Text(
                                  '${allocation.allocatedQuantity}',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Available'),
                                Text(
                                  '${product.quantity}',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Unit Price'),
                                Text(
                                  '\$${product.price.toStringAsFixed(2)}',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildInfoTab() {
    final progress = (_project.tasks.isNotEmpty)
        ? _project.tasks
                .where((t) => t.status == TaskStatus.Completed)
                .length /
            _project.tasks.length * 100
        : 0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Progress Section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Project Progress',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 12),
                  LinearProgressIndicator(
                    value: progress / 100,
                    backgroundColor: Colors.grey[200],
                    color: AdaptiveColors.primaryGreen,
                    minHeight: 12,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${progress.toStringAsFixed(0)}% Complete'),
                      Text(
                        '${_project.tasks.where((t) => t.status == TaskStatus.Completed).length}'
                        '/${_project.tasks.length} Tasks',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Description Section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Description',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _project.description ?? 'No description provided',
                    style: TextStyle(
                      color: _project.description != null
                          ? AdaptiveColors.primaryTextColor(context)
                          : AdaptiveColors.secondaryTextColor(context),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Details Section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Project Details',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  _buildDetailRow('Start Date', _formatDate(_project.beginDate)),
                  const Divider(),
                  _buildDetailRow('End Date', _formatDate(_project.endDate)),
                  const Divider(),
                  _buildDetailRow('Project Manager', _project.projectManager.name),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(value),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(dynamic status) {
    if (status is TaskStatus) {
      switch (status) {
        case TaskStatus.ToDo:
          return Colors.orange;
        case TaskStatus.InProgress:
          return Colors.blue;
        case TaskStatus.Completed:
          return Colors.green;
        case TaskStatus.InReview:
          return Colors.purple;
      }
    } else if (status is ProjectStatus) {
      switch (status) {
        case ProjectStatus.toDo:
          return Colors.orange;
        case ProjectStatus.inProgress:
          return Colors.blue;
        case ProjectStatus.completed:
          return Colors.green;
        case ProjectStatus.cancelled:
          return Colors.red;
      }
    }
    return Colors.grey;
  }

  IconData _getStatusIcon(dynamic status) {
    if (status is TaskStatus) {
      switch (status) {
        case TaskStatus.ToDo:
          return Icons.radio_button_unchecked;
        case TaskStatus.InProgress:
          return Icons.schedule;
        case TaskStatus.Completed:
          return Icons.check_circle;
        case TaskStatus.InReview:
          return Icons.rate_review;
      }
    } else if (status is ProjectStatus) {
      switch (status) {
        case ProjectStatus.toDo:
          return Icons.radio_button_unchecked;
        case ProjectStatus.inProgress:
          return Icons.schedule;
        case ProjectStatus.completed:
          return Icons.check_circle;
        case ProjectStatus.cancelled:
          return Icons.cancel;
      }
    }
    return Icons.help_outline;
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _TabBarDelegate(this.tabBar);

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: AdaptiveColors.cardColor(context),
      child: tabBar,
    );
  }

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  bool shouldRebuild(_TabBarDelegate oldDelegate) => false;
}

// Custom clipper for wave effect
class WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    
    path.lineTo(0, size.height * 0.3);
    
    // Create wave effect
    final firstControlPoint = Offset(size.width * 0.25, size.height * 0.7);
    final firstEndPoint = Offset(size.width * 0.5, size.height * 0.5);
    
    path.quadraticBezierTo(
      firstControlPoint.dx, firstControlPoint.dy,
      firstEndPoint.dx, firstEndPoint.dy,
    );
    
    final secondControlPoint = Offset(size.width * 0.75, size.height * 0.3);
    final secondEndPoint = Offset(size.width, size.height * 0.6);
    
    path.quadraticBezierTo(
      secondControlPoint.dx, secondControlPoint.dy,
      secondEndPoint.dx, secondEndPoint.dy,
    );
    
    path.lineTo(size.width, 0);
    path.lineTo(0, 0);
    path.close();
    
    return path;
  }
  
  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
