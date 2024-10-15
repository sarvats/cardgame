import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async'; 

void main() {
  runApp(const MatchGame());
}

class MatchGame extends StatelessWidget {
  const MatchGame({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Card Matching Game',
      theme: ThemeData(useMaterial3: true),
      home: ChangeNotifierProvider(
        create: (_) => GameState(),
        child: const CardScreen(),
      ),
    );
  }
}

class CardScreen extends StatelessWidget {
  const CardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final gameState = Provider.of<GameState>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Card Matching Game'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4, 
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: gameState.cards.length,
          itemBuilder: (context, index) {
            return ChangeNotifierProvider.value(
              value: gameState.cards[index],
              child: const WidgetCard(),
            );
          },
        ),
      ),
    );
  }
}

class WidgetCard extends StatelessWidget {
  const WidgetCard({super.key});

  @override
  Widget build(BuildContext context) {
    final card = Provider.of<CardModel>(context);
    final gameState = Provider.of<GameState>(context, listen: false);

    return GestureDetector(
      onTap: () {
        if (!card.isFaceUp && !gameState.isChecking) {
          gameState.flipState(card);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        decoration: BoxDecoration(
          color: card.isFaceUp ? Colors.black : Colors.grey,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            card.isFaceUp ? card.frontDesign : card.backDesign,
            style: const TextStyle(fontSize: 24, color: Colors.white),
          ),
        ),
      ),
    );
  }
}

class CardModel with ChangeNotifier {
  final String frontDesign;
  final String backDesign;
  bool isFaceUp;

  CardModel({
    required this.frontDesign,
    required this.backDesign,
    this.isFaceUp = false,
  });

  void flipState() {
    isFaceUp = !isFaceUp;
    notifyListeners();
  }
}

class GameState with ChangeNotifier {
  List<CardModel> flippedCards = [];
  bool isChecking = false;

  final List<CardModel> cards = List.generate(
    16,
    (index) => CardModel(
      frontDesign: (index % 8).toString(), 
      backDesign: 'Flip me!',
    ),
  )..shuffle();

  void flipState(CardModel card) {
    card.flipState();
    flippedCards.add(card);

    if (flippedCards.length == 2) {
      isChecking = true;
      _checkForMatch();
    }

    notifyListeners();
  }

  void _checkForMatch() async {
    await Future.delayed(const Duration(seconds: 1));

    if (flippedCards[0].frontDesign != flippedCards[1].frontDesign) {
      flippedCards[0].flipState();
      flippedCards[1].flipState();
    }

    flippedCards.clear();
    isChecking = false;
    notifyListeners();
  }
}
