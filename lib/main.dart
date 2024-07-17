import 'package:flutter/material.dart';
import 'package:playing_cards/playing_cards.dart';

void main() {
  runApp(MaterialApp(
    theme: ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue.shade700),
    ),
    home: const CardHomeView(),
  ));
}

class CardHomeView extends StatefulWidget {
  const CardHomeView({Key? key}) : super(key: key);

  @override
  State<CardHomeView> createState() => _CardHomeViewState();
}

class _CardHomeViewState extends State<CardHomeView> with TickerProviderStateMixin {
  // Dummy cards for each player
  final List<PlayingCard> myCards = [
    PlayingCard(Suit.spades, CardValue.ace),
    PlayingCard(Suit.hearts, CardValue.king),
    PlayingCard(Suit.diamonds, CardValue.ten),
    PlayingCard(Suit.clubs, CardValue.two),
  ];

  final List<PlayingCard> teammateCards = [
    PlayingCard(Suit.spades, CardValue.jack),
    PlayingCard(Suit.hearts, CardValue.queen),
    PlayingCard(Suit.diamonds, CardValue.nine),
    PlayingCard(Suit.clubs, CardValue.three),
  ];

  final List<PlayingCard> opponentLeftCards = [
    PlayingCard(Suit.spades, CardValue.ten),
    PlayingCard(Suit.hearts, CardValue.nine),
    PlayingCard(Suit.diamonds, CardValue.king),
    PlayingCard(Suit.clubs, CardValue.jack),
  ];

  final List<PlayingCard> opponentRightCards = [
    PlayingCard(Suit.spades, CardValue.queen),
    PlayingCard(Suit.hearts, CardValue.jack),
    PlayingCard(Suit.diamonds, CardValue.ace),
    PlayingCard(Suit.clubs, CardValue.king),
  ];

  // Card positions
  List<Offset> cardPositions = [];
  List<bool> cardVisible = [];

  @override
  void initState() {
    super.initState();
    int totalCards = myCards.length + teammateCards.length + opponentLeftCards.length + opponentRightCards.length;
    cardPositions = List.filled(totalCards, Offset.zero);
    cardVisible = List.filled(totalCards, false);
    _dealCards();
  }

  Future<void> _dealCards() async {
    List<List<Offset>> targetPositions = [
      [const Offset(0.1, 0.1), const Offset(0.3, 0.1), const Offset(0.5, 0.1), const Offset(0.7, 0.1)], // Top positions
      [const Offset(0.1, 0.8), const Offset(0.3, 0.8), const Offset(0.5, 0.8), const Offset(0.7, 0.8)], // Bottom positions
      [const Offset(0.05, 0.25), const Offset(0.05, 0.35), const Offset(0.05, 0.45), const Offset(0.05, 0.55)], // Left positions
      [const Offset(0.7, 0.25), const Offset(0.7, 0.35), const Offset(0.7, 0.45), const Offset(0.7, 0.55)], // Right positions
    ];

    for (int round = 0; round < 4; round++) {
      for (int player = 0; player < 4; player++) {
        int cardIndex = round + player * 4;
        Offset target = targetPositions[player][round];
        setState(() {
          cardPositions[cardIndex] = target;
          cardVisible[cardIndex] = true;
        });
        await Future.delayed(const Duration(milliseconds: 500));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green,
      body: Center(
        child: Stack(
          children: _buildCardWidgets(),
        ),
      ),
    );
  }

  List<Widget> _buildCardWidgets() {
    List<Widget> cardWidgets = [];
    List<PlayingCard> allCards = [...myCards,...opponentRightCards ,...teammateCards, ...opponentLeftCards,];
    double screenWidth = MediaQuery.of(context).size.width ;
    double screenHeight = MediaQuery.of(context).size.height;

    for (int i = 0; i < allCards.length; i++) {
      double left = cardPositions[i].dx * screenWidth;
      double top = cardPositions[i].dy * screenHeight;
      double rotationAngle = 0.0;

      // Rotate left and right cards inward
      if (i >= 8 && i < 12) {
        rotationAngle = 3 * 3.14159 / 2; // 270 degrees for left cards
      } else if (i >= 12) {
        rotationAngle = 3.14159 / 2; // 90 degrees for right cards
      }

      cardWidgets.add(
        AnimatedPositioned(
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInExpo,
          left: left,
          top: top,
          child: Opacity(
            opacity: cardVisible[i] ? 1.0 : 0.0,
            child: Transform.rotate(
              angle: rotationAngle,
              child: buildCard(allCards[i]),
            ),
          ),
        ),
      );
    }

    return cardWidgets;
  }

  Widget buildCard(PlayingCard card) {
    return Container(
      margin: const EdgeInsets.all(8),
      width: 80,
      height: 120,
      child: PlayingCardView(
        card: card,
        style: myCardStyles,
        elevation: 0,
        showBack: false,
        shape: RoundedRectangleBorder(
          side: BorderSide.none,
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
    );
  }

  // Custom card styles
  PlayingCardViewStyle myCardStyles = PlayingCardViewStyle(
    suitStyles: {
      Suit.spades: SuitStyle(
        builder: (context) => const FittedBox(
          fit: BoxFit.fitHeight,
          child: Text(
            "♠",
            style: TextStyle(fontSize: 500),
          ),
        ),
        style: TextStyle(color: Colors.grey[800]),
      ),
      Suit.hearts: SuitStyle(
        builder: (context) => const FittedBox(
          fit: BoxFit.fitHeight,
          child: Text(
            "♥",
            style: TextStyle(fontSize: 500, color: Colors.red),
          ),
        ),
        style: const TextStyle(color: Colors.red),
      ),
      Suit.diamonds: SuitStyle(
        builder: (context) => const FittedBox(
          fit: BoxFit.fitHeight,
          child: Text(
            "♦",
            style: TextStyle(fontSize: 700, color: Colors.red),
          ),
        ),
        style: const TextStyle(color: Colors.red),
      ),
      Suit.clubs: SuitStyle(
        builder: (context) => const FittedBox(
          fit: BoxFit.fitHeight,
          child: Text(
            "♣",
            style: TextStyle(fontSize: 500),
          ),
        ),
        style: TextStyle(color: Colors.grey[800]),
      ),
      Suit.joker: SuitStyle(builder: (context) => Container()),
    },
  );
}

