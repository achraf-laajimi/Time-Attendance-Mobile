import 'package:flutter/material.dart';
import 'package:in_out/screens/projects/models/product_model.dart';
import 'services/product_service.dart';
import 'widgets/search_and_filter_bar_projects.dart';

class ProductSelectionScreen extends StatefulWidget {
  final Map<String, int> initialSelections;
  final String? projectId;

  const ProductSelectionScreen({
    super.key,
    required this.initialSelections,
    this.projectId,
  });

  @override
  State<ProductSelectionScreen> createState() => _ProductSelectionScreenState();
}

class _ProductSelectionScreenState extends State<ProductSelectionScreen> {
  List<Product> availableProducts = [];
  List<Product> filteredProducts = [];
  Map<String, int> selectedProducts = {};
  bool isLoading = false;
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    selectedProducts = Map.from(widget.initialSelections);
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() => isLoading = true);
    try {
      final result = await ProductService().getProducts();
      if (result['success'] == true) {
        final products = <Product>[];
        for (var item in (result['data']['products'] as List)) {
          try {
            final product = item is Map<String, dynamic> 
              ? Product.fromJson(item) 
              : item as Product;
            if (product.id.isNotEmpty && product.name.isNotEmpty) {
              products.add(product);
            }
          } catch (e) {
            debugPrint('Failed to parse product: $e');
          }
        }
        setState(() {
          availableProducts = products;
          filteredProducts = products;
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to load products: ${result['message']}')),
          );
        }
      }
    } catch (e) {
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading products: $e')),
        );
      }
    }
  }

  void _onSearchChanged(String query) {
    setState(() {
      filteredProducts = availableProducts.where((product) {
        return product.name.toLowerCase().contains(query.toLowerCase()) ||
            product.reference.toLowerCase().contains(query.toLowerCase());
      }).toList();
    });
  }

  void _onFilterTap(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Filter by Category', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              children: [
                ...availableProducts.map((p) => p.category).toSet().map((category) => ChoiceChip(
                      label: Text(category),
                      selected: filteredProducts.every((p) => p.category == category),
                      onSelected: (selected) {
                        setState(() {
                          filteredProducts = selected
                              ? availableProducts.where((p) => p.category == category).toList()
                              : availableProducts;
                        });
                        Navigator.pop(context);
                      },
                    )),
                ChoiceChip(
                  label: const Text('All'),
                  selected: filteredProducts.length == availableProducts.length,
                  onSelected: (selected) {
                    setState(() => filteredProducts = availableProducts);
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _updateQuantity(Product product, int quantity) {
    setState(() {
      if (quantity > 0 && quantity <= product.quantity) {
        selectedProducts[product.id] = quantity;
      } else if (quantity <= 0) {
        selectedProducts.remove(product.id);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Cannot exceed available quantity (${product.quantity})'),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Products'),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context, selectedProducts);
            },
            child: const Text('Save'),
          ),
        ],
      ),
      body: Column(
        children: [
          SearchAndFilterBar(
            searchController: searchController,
            onSearchChanged: _onSearchChanged,
            onFilterTap: _onFilterTap,
          ),
          if (isLoading)
            const Center(child: CircularProgressIndicator())
          else if (filteredProducts.isEmpty)
            const Center(child: Text('No products available'))
          else
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: filteredProducts.length,
                itemBuilder: (context, index) {
                  final product = filteredProducts[index];
                  final quantity = selectedProducts[product.id] ?? 0;
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  product.name,
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                              ),
                              Chip(
                                label: Text('${product.quantity} available'),
                                backgroundColor: product.quantity > 0
                                    ? Colors.green[100]
                                    : Colors.red[100],
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Ref: ${product.reference} | Category: ${product.category}',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Price: \$${product.price.toStringAsFixed(2)}',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.remove),
                                    onPressed: () {
                                      if (quantity > 0) {
                                        _updateQuantity(product, quantity - 1);
                                      }
                                    },
                                  ),
                                  Text(quantity.toString()),
                                  IconButton(
                                    icon: const Icon(Icons.add),
                                    onPressed: () {
                                      _updateQuantity(product, quantity + 1);
                                    },
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
      ),
    );
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}