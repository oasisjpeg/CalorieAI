import 'package:flutter/material.dart';
import 'package:calorieai/l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

class ReferencesScreen extends StatelessWidget {
  const ReferencesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).settingsReferencesLabel),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildSection(
            context,
            title: 'Energy Expenditure Calculations',
            references: [
              _Reference(
                title: 'Dietary Reference Intakes for Energy, Carbohydrate, Fiber, Fat, Fatty Acids, Cholesterol, Protein, and Amino Acids',
                authors: 'Institute of Medicine',
                year: '2005',
                publisher: 'The National Academies Press',
                page: 'p.204',
                url: 'https://nap.nationalacademies.org/read/10490/chapter/7#204',
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSection(
            context,
            title: 'Nutritional Guidelines',
            references: [
              _Reference(
                title: 'Dietary Guidelines for Americans',
                authors: 'U.S. Department of Agriculture and U.S. Department of Health and Human Services',
                year: '2020-2025',
                edition: '9th Edition',
                url: 'https://www.dietaryguidelines.gov/',
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSection(
            context,
            title: 'Physical Activity',
            references: [
              _Reference(
                title: '2011 Compendium of Physical Activities',
                authors: 'Ainsworth et al.',
                year: '2011',
                journal: 'Medicine & Science in Sports & Exercise',
                volume: '43',
                issue: '8',
                pages: '1575-1581',
                doi: '10.1249/MSS.0b013e31821ece12',
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'The information provided by this application is for educational and informational purposes only and is not intended as medical advice. Always consult a healthcare professional before making any changes to your diet or exercise routine.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontStyle: FontStyle.italic,
                  color: Theme.of(context).hintColor,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required List<_Reference> references,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        ...references.map((ref) => _buildReferenceItem(context, ref)).toList(),
      ],
    );
  }

  Widget _buildReferenceItem(BuildContext context, _Reference ref) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (ref.authors != null)
            Text(
              '${ref.authors} (${ref.year}).',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          Text(
            ref.title,
            style: const TextStyle(fontStyle: FontStyle.italic),
          ),
          if (ref.journal != null) Text(ref.journal!),
          if (ref.volume != null && ref.issue != null)
            Text('${ref.volume}(${ref.issue})'),
          if (ref.pages != null) Text('pp. ${ref.pages}'),
          if (ref.page != null) Text('p. ${ref.page}'),
          if (ref.edition != null) Text('${ref.edition} Edition'),
          if (ref.publisher != null) Text(ref.publisher!),
          if (ref.doi != null || ref.url != null)
            Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: GestureDetector(
                onTap: () async {
                  final Uri uri = Uri.parse(ref.doi != null 
                      ? 'https://doi.org/${ref.doi}' 
                      : ref.url!);
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                  }
                },
                child: Text(
                  ref.doi != null ? 'DOI: ${ref.doi}' : ref.url!,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _Reference {
  final String title;
  final String? authors;
  final String? year;
  final String? journal;
  final String? volume;
  final String? issue;
  final String? pages;
  final String? page;
  final String? edition;
  final String? doi;
  final String? url;
  final String? publisher;

  _Reference({
    required this.title,
    this.authors,
    this.year,
    this.journal,
    this.volume,
    this.issue,
    this.pages,
    this.page,
    this.edition,
    this.doi,
    this.url,
    this.publisher,
  });
}
