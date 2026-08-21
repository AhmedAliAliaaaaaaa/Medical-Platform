import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/language_provider.dart';
import '../../providers/case_provider.dart';
import '../../widgets/case_card.dart';
import 'case_details_screen.dart';

class CaseListScreen extends StatefulWidget {
  const CaseListScreen({super.key});

  @override
  State<CaseListScreen> createState() => _CaseListScreenState();
}

class _CaseListScreenState extends State<CaseListScreen> {
  String _selectedStatus = 'all';

  @override
  void initState() {
    super.initState();
    _loadCases();
  }

  void _loadCases() async {
    final caseProvider = Provider.of<CaseProvider>(context, listen: false);
    await caseProvider.getMyCases();
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final caseProvider = Provider.of<CaseProvider>(context);
    final isRTL = languageProvider.isRTL;

    final filteredCases =
        _selectedStatus == 'all'
            ? caseProvider.myCases
            : caseProvider.myCases
                .where((c) => c.status == _selectedStatus)
                .toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Directionality(
          textDirection: languageProvider.textDirection,
          child: Column(
            children: [
              // Filter Tabs
              Container(
                padding: const EdgeInsets.all(20),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterTab('all', isRTL ? 'الكل' : 'All', isRTL),
                      _buildFilterTab(
                        'pending',
                        isRTL ? 'في الانتظار' : 'Pending',
                        isRTL,
                      ),
                      _buildFilterTab(
                        'in_progress',
                        isRTL ? 'قيد المعالجة' : 'In Progress',
                        isRTL,
                      ),
                      _buildFilterTab(
                        'completed',
                        isRTL ? 'مكتملة' : 'Completed',
                        isRTL,
                      ),
                    ],
                  ),
                ),
              ),

              // Cases List
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    _loadCases();
                  },
                  child:
                      caseProvider.isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : filteredCases.isEmpty
                          ? _buildEmptyState(isRTL)
                          : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            itemCount: filteredCases.length,
                            itemBuilder: (context, index) {
                              final medicalCase = filteredCases[index];
                              return CaseCard(
                                medicalCase: medicalCase,
                                showDoctorInfo: true,
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder:
                                          (_) => CaseDetailsScreen(
                                            caseId: medicalCase.id,
                                          ),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterTab(String status, String label, bool isRTL) {
    final isSelected = _selectedStatus == status;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedStatus = status;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF667eea) : Colors.white,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color:
                isSelected
                    ? const Color(0xFF667eea)
                    : Colors.grey.withOpacity(0.3),
          ),
          boxShadow:
              isSelected
                  ? [
                    BoxShadow(
                      color: const Color(0xFF667eea).withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ]
                  : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : const Color(0xFF64748B),
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isRTL) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.medical_information_outlined,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 20),
            Text(
              isRTL ? 'لا توجد حالات' : 'No Cases Found',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              isRTL
                  ? 'لم يتم العثور على حالات بالفلتر المحدد'
                  : 'No cases found with the selected filter',
              style: TextStyle(fontSize: 16, color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
