import 'package:flutter/material.dart';
import '../models/quiz.dart';

class QuizConfig {
  final IconData questionIcon;
  final EdgeInsets contentPadding;
  final EdgeInsets optionPadding;

  const QuizConfig({
    this.questionIcon = Icons.quiz,
    this.contentPadding = const EdgeInsets.all(12),
    this.optionPadding = const EdgeInsets.symmetric(
      horizontal: 12,
      vertical: 8,
    ),
  });
}

class QuizWidget extends StatefulWidget {
  final Quiz quiz;
  final Function(String) onAnswerSelected;
  final bool showResult;
  final QuizConfig config;

  const QuizWidget({
    Key? key,
    required this.quiz,
    required this.onAnswerSelected,
    this.showResult = false,
    this.config = const QuizConfig(),
  }) : super(key: key);

  @override
  State<QuizWidget> createState() => _QuizWidgetState();
}

class _QuizWidgetState extends State<QuizWidget> {
  String? _selectedAnswer;
  bool _hasAnswered = false;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final maxWidth = (screenWidth * 0.618) - 32;
    final colorScheme = Theme.of(context).colorScheme;

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Card(
          elevation: 0,
          color: colorScheme.surfaceVariant,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
              bottomLeft: Radius.circular(4),
              bottomRight: Radius.circular(20),
            ),
          ),
          child: Padding(
            padding: widget.config.contentPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Icon(
                      widget.config.questionIcon,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        widget.quiz.question,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ...widget.quiz.options
                    .map((option) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: InkWell(
                            onTap: _hasAnswered
                                ? null
                                : () {
                                    setState(() {
                                      _selectedAnswer = option;
                                      _hasAnswered = true;
                                    });
                                    widget.onAnswerSelected(option);
                                  },
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              width: double.infinity,
                              padding: widget.config.optionPadding,
                              decoration: BoxDecoration(
                                color: _getOptionColor(option),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: _getOptionBorderColor(option),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      option,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                            color: _getTextColor(option),
                                          ),
                                    ),
                                  ),
                                  if (_hasAnswered && widget.showResult)
                                    Icon(
                                      option == widget.quiz.correctAnswer
                                          ? Icons.check_circle
                                          : (_selectedAnswer == option
                                              ? Icons.cancel
                                              : null),
                                      color: option == widget.quiz.correctAnswer
                                          ? colorScheme.primary
                                          : (_selectedAnswer == option
                                              ? colorScheme.error
                                              : null),
                                      size: 20,
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ))
                    .toList(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getTextColor(String option) {
    final colorScheme = Theme.of(context).colorScheme;
    if (!_hasAnswered) {
      return colorScheme.onSurfaceVariant;
    }
    if (option == widget.quiz.correctAnswer) {
      return colorScheme.primary;
    }
    if (_selectedAnswer == option) {
      return colorScheme.error;
    }
    return colorScheme.onSurfaceVariant;
  }

  Color _getOptionColor(String option) {
    final colorScheme = Theme.of(context).colorScheme;
    if (!_hasAnswered) {
      return Colors.transparent;
    }
    if (option == widget.quiz.correctAnswer) {
      return colorScheme.primary.withOpacity(0.1);
    }
    if (_selectedAnswer == option) {
      return colorScheme.error.withOpacity(0.1);
    }
    return Colors.transparent;
  }

  Color _getOptionBorderColor(String option) {
    final colorScheme = Theme.of(context).colorScheme;
    if (!_hasAnswered) {
      return colorScheme.outline;
    }
    if (option == widget.quiz.correctAnswer) {
      return colorScheme.primary;
    }
    if (_selectedAnswer == option) {
      return colorScheme.error;
    }
    return colorScheme.outline;
  }
}
