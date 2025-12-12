import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart' as file_picker;
import 'package:in_out/theme/adaptive_colors.dart';
import 'package:in_out/screens/projects/models/task_model.dart';
import 'models/ExpressUser.dart';
import 'services/task_service.dart';
import 'services/user_service.dart';
import 'widgets/image_viewer.dart';

class TaskDetailsScreen extends StatefulWidget {
  final Task task;

  const TaskDetailsScreen({
    super.key,
    required this.task,
  });

  @override
  State<TaskDetailsScreen> createState() => _TaskDetailsScreenState();
}

class _TaskDetailsScreenState extends State<TaskDetailsScreen> {
  late Task _task;
  final TextEditingController _commentController = TextEditingController();
  final TaskService _taskService = TaskService();
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _task = widget.task;
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _refreshTask() async {
    try {
      final response = await _taskService.getProjectTasks(_task.project);
      if (response['success'] == true) {
        final groupedTasks = response['data']['tasks'] as Map<String, List<Task>>;
        for (var taskList in groupedTasks.values) {
          for (var task in taskList) {
            if (task.id == _task.id) {
              setState(() => _task = task);
              break;
            }
          }
        }
      }
    } catch (e) {
      _showErrorSnackbar('Error refreshing task: ${e.toString()}');
    } finally {
    }
  }

  Future<void> _addComment() async {
    if (_commentController.text.trim().isEmpty) return;

    try {
      final response = await _taskService.addComment(
        taskId: _task.id,
        content: _commentController.text,
      );
      if (response['success'] == true) {
        setState(() {
          _task = response['data'] as Task;
          _commentController.clear();
        });
      } else {
        _showErrorSnackbar(response['message'] ?? 'Failed to add comment');
      }
    } catch (e) {
      _showErrorSnackbar('Error adding comment: ${e.toString()}');
    } finally {
    }
  }

  Future<void> _addAttachments() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: file_picker.FileType.any,
      );

      if (result != null && result.files.isNotEmpty) {
        final filePaths = result.files.map((file) => file.path!).where((path) => path != null).toList();
        final response = await _taskService.addTaskAttachments(
          taskId: _task.id,
          filePaths: filePaths,
        );
        
        if (response['success'] == true) {
          setState(() => _task = response['data'] as Task);
        } else {
          _showErrorSnackbar(response['message'] ?? 'Failed to add attachments');
        }
      }
    } catch (e) {
      _showErrorSnackbar('Error adding attachments: ${e.toString()}');
    } finally {
    }
  }

  Future<void> _addWorkEvidence() async {
    try {
      final pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        final response = await _taskService.addWorkEvidence(
          taskId: _task.id,
          imagePaths: [pickedFile.path],
        );
        
        if (response['success'] == true) {
          setState(() => _task = response['data'] as Task);
        } else {
          _showErrorSnackbar(response['message'] ?? 'Failed to add work evidence');
        }
      }
    } catch (e) {
      _showErrorSnackbar('Error adding work evidence: ${e.toString()}');
    } finally {
    }
  }

  Future<void> _removeAttachment(String attachmentId) async {
    try {
      final response = await _taskService.removeTaskAttachments(
        taskId: _task.id,
        attachmentIds: [attachmentId],
      );
      
      if (response['success'] == true) {
        setState(() => _task = response['data'] as Task);
      } else {
        _showErrorSnackbar(response['message'] ?? 'Failed to remove attachment');
      }
    } catch (e) {
      _showErrorSnackbar('Error removing attachment: ${e.toString()}');
    } finally {
    }
  }

  Future<void> _removeWorkEvidence(String evidenceId) async {
    try {
      final response = await _taskService.removeWorkEvidence(
        taskId: _task.id,
        evidenceIds: [evidenceId],
      );
      
      if (response['success'] == true) {
        setState(() => _task = response['data'] as Task);
      } else {
        _showErrorSnackbar(response['message'] ?? 'Failed to remove work evidence');
      }
    } catch (e) {
      _showErrorSnackbar('Error removing work evidence: ${e.toString()}');
    } finally {
    }
  }

  Future<void> _updateTaskStatus(TaskStatus newStatus) async {
    try {
      final response = await _taskService.updateTaskStatus(
        taskId: _task.id,
        status: newStatus,
      );
      
      if (response['success'] == true) {
        setState(() => _task = response['data'] as Task);
        _showSuccessSnackbar('Task status updated successfully');
      } else {
        _showErrorSnackbar(response['message'] ?? 'Failed to update status');
      }
    } catch (e) {
      _showErrorSnackbar('Error updating status: ${e.toString()}');
    } finally {
    }
  }

  Future<void> _deleteTask() async {
    try {
      final response = await _taskService.deleteTask(_task.id);
      if (response['success'] == true) {
        Navigator.pop(context, null);
        _showSuccessSnackbar('Task deleted successfully');
      } else {
        _showErrorSnackbar(response['message'] ?? 'Failed to delete task');
      }
    } catch (e) {
      _showErrorSnackbar('Error deleting task: ${e.toString()}');
    } finally {
    }
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  Widget _buildAttachmentCard(Attachment attachment) {
    return GestureDetector(
      onLongPress: () => _showDeleteDialog(
        'Delete Attachment',
        'Are you sure you want to delete ${attachment.name}?',
        () => _removeAttachment(attachment.id),
      ),
      child: Card(
        child: Container(
          width: 120,
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _getFileTypeIcon(attachment.fileType as file_picker.FileType),
                size: 32,
              ),
              const SizedBox(height: 4),
              Text(
                attachment.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWorkEvidenceItem(WorkEvidence evidence) {
    return GestureDetector(
      onLongPress: () => _showDeleteDialog(
        'Delete Evidence',
        'Are you sure you want to delete this work evidence?',
        () => _removeWorkEvidence(evidence.id),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          evidence.imageUrl,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Center(child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                  : null,
            ));
          },
          errorBuilder: (context, error, stackTrace) => const Center(child: Icon(Icons.broken_image)),
        ),
      ),
    );
  }

  void _showDeleteDialog(String title, String content, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onConfirm();
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _refreshTask,
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 200,
              pinned: true,
              floating: false,
              snap: false,
              stretch: false,
              collapsedHeight: 180,
              leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Navigator.pop(context, _task), 
              ),
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
                collapseMode: CollapseMode.pin,
                title: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Task Name
                      Text(
                        _task.name,
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(
                              color: Colors.white.withOpacity(0.8),
                              blurRadius: 10,
                              offset: const Offset(1, 1),
                            ),
                          ],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      
                      Row(
                        children: [
                          _buildStatusChip(_task.status),
                          const SizedBox(width: 8),
                          _buildPriorityChip(_task.priority),
                        ],
                      ),
                    ],
                  ),
                ),
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        _getStatusColor(_task.status).withOpacity(0.8),
                        _getStatusColor(_task.status).withOpacity(0.4),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Main Content
            SliverList(
              delegate: SliverChildListDelegate([
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Description Section
                      _buildSection(
                        context,
                        title: 'Description',
                        child: Text(
                          _task.description,
                          style: theme.textTheme.bodyLarge,
                        ),
                      ),

                      // Assigned To Section
                      _buildSection(
                        context,
                        title: 'Assigned To',
                        child: FutureBuilder<Map<String, dynamic>>(
                          future: ExpressUserService().getUserById(_task.assignedTo!), 
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: CircularProgressIndicator(),
                                title: Text('Loading...'),
                              );
                            } else if (snapshot.hasError || !snapshot.hasData || snapshot.data!['success'] != true) {
                              return ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: CircleAvatar(
                                  backgroundColor: AdaptiveColors.getPrimaryColor(context).withOpacity(0.2),
                                  child: const Icon(Icons.error, color: Colors.red),
                                ),
                                title: const Text('Error'),
                                subtitle: Text(snapshot.data?['message'] ?? 'Failed to load user'),
                              );
                            } else {
                              final user = snapshot.data!['data'] as ExpressUser;
                              return ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: CircleAvatar(
                                  backgroundColor: AdaptiveColors.getPrimaryColor(context).withOpacity(0.2),
                                  child: Text(
                                    user.name.substring(0, 1).toUpperCase(),
                                    style: TextStyle(
                                      color: AdaptiveColors.getPrimaryColor(context),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                title: Text(
                                  user.name,
                                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                subtitle: Text(
                                  user.email,
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              );
                            }
                          },
                        ),
                      ),

                      // Timeline Section
                      _buildSection(
                        context,
                        title: 'Timeline',
                        child: Column(
                          children: [
                            LinearProgressIndicator(
                              value: _calculateProgress(_task.beginDate, _task.endDate),
                              backgroundColor: Colors.grey[200],
                              color: _getStatusColor(_task.status),
                              minHeight: 8,
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${DateFormat('MMM d').format(_task.beginDate)}',
                                  style: theme.textTheme.bodySmall,
                                ),
                                Text(
                                  '${DateFormat('MMM d').format(_task.endDate)}',
                                  style: theme.textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      _buildSection(
                        context,
                        title: 'Attachments (${_task.attachments.length})',
                        child: _task.attachments.isEmpty
                            ? Padding(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                child: Text(
                                  'No attachments yet',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: AdaptiveColors.secondaryTextColor(context),
                                  ),
                                ),
                              )
                            : SizedBox(
                                height: 100,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: _task.attachments.length,
                                  itemBuilder: (context, index) {
                                    final attachment = _task.attachments[index];
                                    return GestureDetector(
                                      onTap: () {
                                        if (attachment.fileType == file_picker.FileType.image) {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => ImageViewer(
                                                imageUrl: attachment.url,
                                                title: attachment.name,
                                              ),
                                            ),
                                          );
                                        } else {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text('Opening ${attachment.name}'),
                                            ),
                                          );
                                        }
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.only(right: 8),
                                        child: _buildAttachmentCard(attachment),
                                      ),
                                    );
                                  },
                                ),
                              ),
                      ),

                      _buildSection(
                        context,
                        title: 'Work Evidence (${_task.workEvidence.length})',
                        child: _task.workEvidence.isEmpty
                            ? Padding(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                child: Text(
                                  'No work evidence yet',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: AdaptiveColors.secondaryTextColor(context),
                                  ),
                                ),
                              )
                            : ConstrainedBox(
                                constraints: BoxConstraints(
                                  maxHeight: MediaQuery.of(context).size.height * 0.4,
                                ),
                                child: GridView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 3,
                                    crossAxisSpacing: 8,
                                    mainAxisSpacing: 8,
                                  ),
                                  itemCount: _task.workEvidence.length,
                                  itemBuilder: (context, index) {
                                    final evidence = _task.workEvidence[index];
                                    return GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => ImageViewer(
                                              imageUrl: evidence.imageUrl,
                                              title: evidence.originalName,
                                            ),
                                          ),
                                        );
                                      },
                                      child: _buildWorkEvidenceItem(evidence),
                                    );
                                  },
                                ),
                              ),
                      ),

                      // Comments Section
                      _buildSection(
                        context,
                        title: 'Comments (${_task.comments.length})',
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxHeight: MediaQuery.of(context).size.height * 0.4,
                          ),
                          child: SingleChildScrollView(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (_task.comments.isEmpty)
                                  Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    child: Text(
                                      'No comments yet',
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        color: AdaptiveColors.secondaryTextColor(context),
                                      ),
                                    ),
                                  ),
                                ..._task.comments.map((comment) => _buildCommentItem(context, comment)).toList(),
                                const SizedBox(height: 16),
                                TextField(
                                  controller: _commentController,
                                  decoration: InputDecoration(
                                    hintText: 'Add a comment...',
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        Icons.send,
                                        color: AdaptiveColors.getPrimaryColor(context),
                                      ),
                                      onPressed: _addComment,
                                    ),
                                  ),
                                  onSubmitted: (value) => _addComment(),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ]),
            ),
          ],
        ),
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            builder: (context) => _buildActionSheet(context),
          );
        },
        icon: const Icon(Icons.more_vert),
        label: const Text('Actions'),
        backgroundColor: AdaptiveColors.getPrimaryColor(context),
      ),
    );
  }

  Widget _buildSection(BuildContext context, {required String title, required Widget child}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: child,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(TaskStatus status) {
    return Chip(
      label: Text(
        status.toString().split('.').last,
        style: TextStyle(
          color: _getStatusColor(status),
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: _getStatusColor(status).withOpacity(0.2),
      side: BorderSide(
        color: _getStatusColor(status),
        width: 1,
      ),
    );
  }

  Widget _buildPriorityChip(TaskPriority priority) {
    return Chip(
      label: Text(
        priority.toString().split('.').last,
        style: TextStyle(
          color: _getPriorityColor(priority),
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: _getPriorityColor(priority).withOpacity(0.2),
      side: BorderSide(
        color: _getPriorityColor(priority),
        width: 1,
      ),
    );
  }


  Widget _buildCommentItem(BuildContext context, Comment comment) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: AdaptiveColors.getPrimaryColor(context).withOpacity(0.2),
            child: Text(
              comment.user.substring(0, 1).toUpperCase(),
              style: TextStyle(
                color: AdaptiveColors.getPrimaryColor(context),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'User Name', // Replace with actual user name
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  comment.content,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat('MMM d, y • h:mm a').format(comment.createdAt),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AdaptiveColors.secondaryTextColor(context),
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionSheet(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.attach_file),
            title: const Text('Add Attachment'),
            onTap: () {
              Navigator.pop(context);
              _addAttachments();
            },
          ),
          ListTile(
            leading: const Icon(Icons.camera_alt),
            title: const Text('Add Work Evidence'),
            onTap: () {
              Navigator.pop(context);
              _addWorkEvidence();
            },
          ),
          if (_task.status != TaskStatus.Completed)
            ListTile(
              leading: const Icon(Icons.check_circle),
              title: const Text('Mark as Complete'),
              onTap: () {
                _updateTaskStatus(TaskStatus.Completed);
                Navigator.pop(context);
              },
            ),
          if (_task.status == TaskStatus.InProgress)
            ListTile(
              leading: const Icon(Icons.rate_review),
              title: const Text('Send for Review'),
              onTap: () {
                Navigator.pop(context);
                _updateTaskStatus(TaskStatus.InReview);
              },
            ),
          ListTile(
            leading: const Icon(Icons.delete, color: Colors.red),
            title: const Text('Delete Task', style: TextStyle(color: Colors.red)),
            onTap: () {
              Navigator.pop(context);
              _showDeleteConfirmation(context);
            },
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Task?'),
        content: Text('Are you sure you want to delete "${_task.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteTask();
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getFileTypeIcon(file_picker.FileType fileType) {
    switch (fileType) {
      case file_picker.FileType.image:
        return Icons.image;
      case file_picker.FileType.custom:
        return Icons.description;
      case file_picker.FileType.any:
        return Icons.insert_drive_file;
      case file_picker.FileType.media:
        // TODO: Handle this case.
        throw UnimplementedError();
      case file_picker.FileType.video:
        // TODO: Handle this case.
        throw UnimplementedError();
      case file_picker.FileType.audio:
        // TODO: Handle this case.
        throw UnimplementedError();
    }
  }

  Color _getStatusColor(TaskStatus status) {
    switch (status) {
      case TaskStatus.ToDo:
        return Colors.orange;
      case TaskStatus.InProgress:
        return Colors.blue;
      case TaskStatus.InReview:
        return Colors.purple;
      case TaskStatus.Completed:
        return Colors.green;
    }
  }

  Color _getPriorityColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.Low:
        return Colors.green;
      case TaskPriority.Medium:
        return Colors.blue;
      case TaskPriority.High:
        return Colors.orange;
      case TaskPriority.Urgent:
        return Colors.red;
    }
  }

  double _calculateProgress(DateTime start, DateTime end) {
    final now = DateTime.now();
    if (now.isBefore(start)) return 0;
    if (now.isAfter(end)) return 1;
    final totalDuration = end.difference(start).inSeconds;
    final elapsedDuration = now.difference(start).inSeconds;
    return elapsedDuration / totalDuration;
  }
}