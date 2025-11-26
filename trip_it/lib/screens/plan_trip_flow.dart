import 'package:flutter/material.dart';
// Import the new ResultsStep widget from the new file
import 'results_step.dart';

// --- PLACEHOLDER WIDGETS (Required for PlanTripFlow) ---

// Placeholder for the Gradient Button
class _GradientButton extends StatelessWidget {
  final String label;
  final bool enabled;
  final VoidCallback onPressed;
  final List<Color> colors;

  const _GradientButton({
    required this.label,
    required this.enabled,
    required this.onPressed,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          gradient: enabled
              ? LinearGradient(
                  colors: colors,
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                )
              : null,
          color: enabled ? null : Colors.grey.shade400,
        ),
        child: ElevatedButton(
          onPressed: enabled ? onPressed : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent, // Use Container's gradient
            shadowColor: Colors.transparent,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16),
            disabledForegroundColor: Colors.white70,
          ),
          child: Text(
            label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}

// -------------------------------------------------------------
// MAIN WIDGET
// -------------------------------------------------------------

class PlanTripFlow extends StatefulWidget {
  final String? initialQuery;
  const PlanTripFlow({super.key, this.initialQuery});
  static const route = '/plan-trip';

  @override
  State<PlanTripFlow> createState() => _PlanTripFlowState();
}

class _PlanTripFlowState extends State<PlanTripFlow> {
  int step = 0; // 0: Budget, 1: Weather, 2: Style, 3: Results

  String? budget; // budget_low, budget_mid, budget_high
  String? weather; // warm, mild, cool
  String? style; // relax, cultural, heritage

  void _next() {
    setState(() => step = (step + 1).clamp(0, 3));
  }

  void _back() {
    if (step > 0) setState(() => step--);
  }

  // New method for handling 'Modify Preferences' button press from ResultsStep
  void _modifyPreferences() {
    setState(() => step = 0);
  }

  @override
  void initState() {
    super.initState();
    // If launched with an initial query, jump to results directly
    if (widget.initialQuery != null) {
      step = 3;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Apply sky blue background only to steps 0, 1, and 2, as ResultsStep now manages its own background.
    final Color contentBackgroundColor = step < 3
        ? Colors.lightBlue.shade50
        : Colors.white;

    return Scaffold(
      backgroundColor:
          Colors.lightBlue.shade50, // Set the main background to sky blue
      appBar: AppBar(
        centerTitle: true,
        title: Text(_titleForStep(step)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: step == 0 ? () => Navigator.pop(context) : _back,
        ),
        // AppBar background matches the content background for steps 0-2
        backgroundColor: contentBackgroundColor,
      ),
      body: SafeArea(
        child: Column(
          children: [
            if (step < 3) ...[
              // Stepper header is only for steps 0, 1, 2
              const SizedBox(height: 8),
              _StepperHeader(step: step),
              const SizedBox(height: 12),
            ],

            Expanded(
              // Apply sky blue background to the content area for steps 0, 1, 2
              // ResultsStep (step 3) manages its own background inside its widget
              child: Container(
                color: contentBackgroundColor,
                child: _buildStepContent(context),
              ),
            ),

            // Only show gradient buttons for steps 0, 1, 2
            if (step < 3) ...[_buildBottomButton(), const SizedBox(height: 12)],
            // Note: ResultsStep (step 3) contains its own floating button
          ],
        ),
      ),
    );
  }

  Widget _buildBottomButton() {
    String label = '';
    VoidCallback? onPressed;
    List<Color> colors = [];
    bool enabled = false;

    // The gradient button is only shown for steps 0, 1, 2
    switch (step) {
      case 0:
        label = 'Continue to Weather Preference';
        colors = [const Color(0xFF5F50F2), const Color(0xFF9F5CFF)];
        enabled = budget != null;
        onPressed = _next;
        break;
      case 1:
        label = 'Continue to Travel Style';
        colors = [const Color(0xFF00BFFF), const Color(0xFF00FFC0)];
        enabled = weather != null;
        onPressed = _next;
        break;
      case 2:
        label = 'Find My Perfect Destinations';
        colors = [const Color(0xFF32CD32), const Color(0xFF00A300)];
        enabled = style != null;
        onPressed = _next;
        break;
      default:
        return const SizedBox.shrink();
    }

    return _GradientButton(
      label: label,
      enabled: enabled,
      onPressed: onPressed,
      colors: colors,
    );
  }

  Widget _buildStepContent(BuildContext context) {
    switch (step) {
      case 0:
        return _BudgetStep(
          selected: budget,
          onSelect: (v) => setState(() => budget = v),
        );
      case 1:
        return _WeatherStep(
          selected: weather,
          onSelect: (v) => setState(() => weather = v),
        );
      case 2:
        return _StyleStep(
          selected: style,
          onSelect: (v) => setState(() => style = v),
        );
      case 3:
        // Use the new ResultsStep widget from the imported file
        return ResultsStep(
          budget: budget,
          weather: weather,
          style: style,
          query: widget.initialQuery,
          onModifyPreferences:
              _modifyPreferences, // Pass the callback to the results page
        );
      default:
        return const Center(child: Text("Error: Invalid Step"));
    }
  }

  String _titleForStep(int s) {
    switch (s) {
      case 0:
        return "Choose Your Budget";
      case 1:
        return "Weather Preference";
      case 2:
        return "Travel Style";
      case 3:
        return "Results"; // Use a simple title since the main title is in the header
      default:
        return '';
    }
  }
}

// ------------------------------------------------------------------
// STEPPER WIDGETS (ICONS BELOW NUMBERS)
// ------------------------------------------------------------------

class _StepperHeader extends StatelessWidget {
  final int step;
  const _StepperHeader({required this.step});

  // Helper to determine the icon based on the step index
  IconData _getIconForStep(int index) {
    switch (index) {
      case 1:
        return Icons.account_balance_wallet_outlined;
      case 2:
        return Icons.cloud_outlined;
      case 3:
        return Icons.beach_access_outlined;
      default:
        return Icons.circle;
    }
  }

  // Helper to determine the color based on the step index for the icon
  Color _getIconColorForStep(int index) {
    switch (index) {
      case 1:
        return const Color(0xFF5F50F2); // Budget (Purple from cards)
      case 2:
        return Colors.orange; // Weather (Orange from cards)
      case 3:
        return Colors.green; // Style (Green from cards)
      default:
        return Colors.black;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        3,
        (i) => Row(
          children: [
            Column(
              children: [
                _Circle(idx: i + 1, active: step >= i, currentStep: step), // Numbers (1, 2, 3)
                const SizedBox(height: 6), // Space between number and icon
                Icon(
                  _getIconForStep(i + 1),
                  color: step >= i
                      ? _getIconColorForStep(i + 1)
                      : Colors.black26, // Color if active/completed
                  size: 24, // Size for the icons below the numbers
                ),
              ],
            ),
            if (i < 2)
              Container(
                width: 48,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20), // Align with icons
                decoration: BoxDecoration(
                  color: step > i ? Colors.green : Colors.black12,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Circle extends StatelessWidget {
  final int idx;
  final bool active; // Means this step or previous steps are active
  final int currentStep;
  const _Circle({required this.idx, required this.active, required this.currentStep});

  @override
  Widget build(BuildContext context) {
    final bool completed = idx <= (currentStep);

    return Container(
      width: 28,
      height: 28,
      alignment: Alignment.center,
      margin: const EdgeInsets.symmetric(horizontal: 0),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: completed ? Colors.green : Colors.white,
        border: Border.all(
          color: active ? Colors.green : Colors.black26,
          width: 2,
        ),
      ),
      child: completed
          ? const Icon(Icons.check, color: Colors.white, size: 18)
          : Text(
              '$idx',
              style: TextStyle(
                color: active ? Colors.black : Colors.black87,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
    );
  }
}

// ------------------------------------------------------------------
// SELECTABLE CARD WIDGETS
// ------------------------------------------------------------------

// Custom Card for Budget Step (Uses Indigo/Purple)
class _SelectCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _SelectCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  // Use the Budget step color for consistency
  final Color cardColor = const Color(0xFF5F50F2);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
        border: Border.all(
          color: selected ? cardColor : Colors.transparent,
          width: 2,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: cardColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: cardColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      subtitle,
                      style: const TextStyle(color: Colors.black54),
                    ),
                  ],
                ),
              ),
              if (selected) Icon(Icons.check_circle, color: cardColor),
            ],
          ),
        ),
      ),
    );
  }
}

// Custom Card for Weather Step (Uses dynamic color based on icon)
class _SelectIconCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _SelectIconCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  // Determine color based on weather type
  Color _getWeatherColor(IconData icon) {
    if (icon == Icons.wb_sunny_outlined) return Colors.deepOrange; // Warm/Sunny
    if (icon == Icons.cloud_queue) return Colors.orange; // Mild/Cloud
    if (icon == Icons.ac_unit) return Colors.lightBlue; // Cool/Snow
    return Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    Color selectedColor = _getWeatherColor(icon);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
        border: Border.all(
          color: selected ? selectedColor : Colors.transparent,
          width: 2,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 36, color: selectedColor),
              const SizedBox(height: 6),
              Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 2),
              Text(subtitle, style: const TextStyle(color: Colors.black54)),
            ],
          ),
        ),
      ),
    );
  }
}

// Custom Card for Style Step (Uses Green)
class _SelectChipsCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final List<String> chips;
  final bool selected;
  final VoidCallback onTap;

  const _SelectChipsCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.chips,
    required this.selected,
    required this.onTap,
  });

  final Color selectedColor = Colors.green;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
        border: Border.all(
          color: selected ? selectedColor : Colors.transparent,
          width: 2,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(icon, size: 40, color: selectedColor),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: const TextStyle(color: Colors.black54),
                        ),
                      ],
                    ),
                  ),
                  if (selected) Icon(Icons.check_circle, color: selectedColor),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: chips
                    .map(
                      (c) => Chip(
                        label: Text(c, style: const TextStyle(fontSize: 12)),
                        backgroundColor: Colors.grey.shade100,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 0,
                        ),
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ------------------------------------------------------------------
// STEP CONTENT VIEWS
// ------------------------------------------------------------------

class _BudgetStep extends StatelessWidget {
  final String? selected;
  final ValueChanged<String> onSelect;
  const _BudgetStep({required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    // Content is wrapped in SingleChildScrollView for scrolling
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "What's your travel budget?",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          const Text(
            'Help us find the perfect destinations within your range',
            style: TextStyle(color: Colors.black54),
          ),
          const SizedBox(height: 16),
          // ICON 1: Hand holding dollar (low budget)
          _SelectCard(
            title: 'Budget Travelers',
            subtitle:
                '\$500 - \$1,500\nExplore amazing places without breaking the bank',
            icon: Icons.attach_money,
            selected: selected == 'budget_low',
            onTap: () => onSelect('budget_low'),
          ),
          // ICON 2: Suitcase (mid budget)
          _SelectCard(
            title: 'Comfort seeker',
            subtitle:
                '\$1,500 - \$3,500\nPerfect balance of comfort and adventure',
            icon: Icons.work_outline,
            selected: selected == 'budget_mid',
            onTap: () => onSelect('budget_mid'),
          ),
          // ICON 3: Crown/Premium (high budget)
          _SelectCard(
            title: 'Luxury Explorer',
            subtitle:
                '\$3,500+\nPremium experiences and five-star accommodations',
            icon: Icons.diamond_outlined,
            selected: selected == 'budget_high',
            onTap: () => onSelect('budget_high'),
          ),
        ],
      ),
    );
  }
}

class _WeatherStep extends StatelessWidget {
  final String? selected;
  final ValueChanged<String> onSelect;
  const _WeatherStep({required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    // Content is wrapped in SingleChildScrollView for scrolling
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "What's your ideal weather?",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          const Text(
            "We'll suggest destinations with your perfect climate",
            style: TextStyle(color: Colors.black54),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _SelectIconCard(
                  title: 'Sunny & Warm',
                  subtitle:
                      '25°C - 35°C\nPerfect for beaches, outdoor activities, and sunbathing',
                  // ICON 1: Sun
                  icon: Icons.wb_sunny_outlined,
                  selected: selected == 'warm',
                  onTap: () => onSelect('warm'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _SelectIconCard(
                  title: 'Mild & Pleasant',
                  subtitle:
                      '15°C - 25°C\nGreat for sightseeing, walking tours, and cultural exploration',
                  // ICON 2: Cloud
                  icon: Icons.cloud_queue,
                  selected: selected == 'mild',
                  onTap: () => onSelect('mild'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _SelectIconCard(
                  title: 'Cool & Crisp',
                  subtitle:
                      '5°C - 15°C\nIdeal for mountain adventures, cozy cafes, and winter sports',
                  // ICON 3: Snowflake
                  icon: Icons.ac_unit,
                  selected: selected == 'cool',
                  onTap: () => onSelect('cool'),
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(child: SizedBox.shrink()),
            ],
          ),
        ],
      ),
    );
  }
}

class _StyleStep extends StatelessWidget {
  final String? selected;
  final ValueChanged<String> onSelect;
  const _StyleStep({required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    // Content is wrapped in SingleChildScrollView for scrolling
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "What's your travel style?",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          const Text(
            "Choose the type of experience you're looking for",
            style: TextStyle(color: Colors.black54),
          ),
          const SizedBox(height: 16),
          // ICON 1: Palm tree/Beach (Relaxation)
          _SelectChipsCard(
            title: 'Relaxation',
            subtitle: 'Beautiful beaches, and peaceful retreats',
            icon: Icons.beach_access_outlined,
            chips: const ['Beach lounging', 'Sunbathing', 'Sunset watching'],
            selected: selected == 'relax',
            onTap: () => onSelect('relax'),
          ),
          // ICON 2: Book (Cultural)
          _SelectChipsCard(
            title: 'Cultural',
            subtitle:
                'Immerse yourself in local traditions, food, and modern city life',
            icon: Icons.menu_book,
            chips: const ['Food tours', 'Local markets', 'Festivals'],
            selected: selected == 'cultural',
            onTap: () => onSelect('cultural'),
          ),
          // ICON 3: Museum/Building (Heritage)
          _SelectChipsCard(
            title: 'Heritage',
            subtitle:
                'Explore ancient monuments, museums, and historical landmarks',
            icon: Icons.account_balance_outlined,
            chips: const ['Rome', 'Athens', 'Cairo'],
            selected: selected == 'heritage',
            onTap: () => onSelect('heritage'),
          ),
        ],
      ),
    );
  }
}
