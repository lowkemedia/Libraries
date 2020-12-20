//
// Playing Cards
//


#include <iostream>
using namespace std;

enum Suit {CLUBS, DIAMONDS, HEARTS, SPADES};
enum Rank {DEUCE, TREY, FOUR, FIVE, SIX, SEVEN, EIGHT, NINE, TEN,
           JACK, QUEEN, KING, ACE};

static const int NUMBER_OF_CARDS = 4;
static const string SUITS[] = {"Clubs", "Diamonds", "Hearts", "Spades"};
static const string RANKS[] = {"Deuce", "Trey", "Four", "Five", "Six", "Seven",
                        "Eight", "Nine", "Ten", "Jack", "Queen", "King", "Ace"};

Suit askSuit()
{
    while(true)
    {
        cout << " Suit: ";
        
        char input;
        cin >> input;
        
        switch (toupper(input))
        {
            case 'C':
                return CLUBS;
            case 'D':
                return DIAMONDS;
            case 'H':
                return HEARTS;
            case 'S':
                return SPADES;
            default:
                cout << input << " is an inavlid suite." << endl;
                break;
        }
    }
}

Rank askRank()
{
    while(true)
    {
        cout << " Rank: ";
        
        char input;
        cin >> input;
        
        switch (toupper(input))
        {
            case '2':
            case '3':
            case '4':
            case '5':
            case '6':
            case '7':
            case '8':
            case '9':
            {
                // use ASCII values to deduce Rank
                int index = input - '2';
                Rank rank = (Rank) index;
                return rank;
            }
            case 'T':
                return TEN;
            case 'J':
                return JACK;
            case 'Q':
                return QUEEN;
            case 'K':
                return KING;
            case 'A':
                return ACE;
            default:
                cout << input << " is an inavlid rank." << endl;
                break;
        }
    }
}

string getSuitName(Suit suit)
{
    return SUITS[suit];
}

string getCardName(Rank rank, Suit suit)
{
    return RANKS[rank] + " of " + getSuitName(suit);
}

string getWinningCard(Suit trumps, Suit suits[], Rank ranks[])
{
    //
    // make a list of winning card indicies,
    //  winnning cards are those that are of the trump Suit
    int nWinngCards = 0;
    int winningCards[NUMBER_OF_CARDS] = {};
    for (int i = 0; i < NUMBER_OF_CARDS; ++i)
    {
        if (suits[i] == trumps)
        {
            winningCards[nWinngCards++] = i;
        }
    }
    
    //
    // if no cards are trumps then consider all cards winning cards
    if (nWinngCards == 0)
    {
        nWinngCards = NUMBER_OF_CARDS;
        for (int i = 0; i < NUMBER_OF_CARDS; ++i)
        {
            winningCards[i] = i;
        }
    }
    
    //
    // find winning card from winning cards list
    int winningCardIndex = -1;
    Rank winningCardRank = DEUCE;
    for (int i = 0; i < nWinngCards; ++i)
    {
        int cardIndex = winningCards[i];
        Rank cardRank = ranks[cardIndex];
        if (winningCardIndex == -1 ||
            cardRank > winningCardRank)
        {
            winningCardIndex = cardIndex;
            winningCardRank = cardRank;
        }
    }
    
    string winningCardName = getCardName(ranks[winningCardIndex],
                                         suits[winningCardIndex]);
    return winningCardName;
}

void playGame()
{
    Suit trump;     // trump suit
    Suit suits[NUMBER_OF_CARDS];    // trick of card suits
    Rank ranks[NUMBER_OF_CARDS];    // trick of card ranks
    
    // ask for trumps
    cout << "TRUMP? ";
    trump = askSuit();
    cout << "TRUMPS is " << getSuitName(trump) << endl;
    
    // ask for card
    for (int i = 0; i < NUMBER_OF_CARDS; ++i)
    {
        int cardNumber = i + 1;
        cout << "CARD " << cardNumber << "? ";
        suits[i] = askSuit();
        ranks[i] = askRank();
        
        string cardName = getCardName(ranks[i], suits[i]);
        cout << "CARD " << cardNumber << " is " << cardName << endl;
    }
    
    // show result
    string winningCardName = getWinningCard(trump, suits, ranks);
    cout << "THE WINNING CARD is " << winningCardName << endl;
}


int main()
{
    char tryAgain;  // used for try again input
    
    //
    // main loop
    do
    {
        playGame();
        
        // try again?
        cout << "Want to try again? (y/n) ";
        cin >> tryAgain;
        tryAgain = tolower(tryAgain);
        
    } while (tryAgain == 'y');

    
    return 0;
}
