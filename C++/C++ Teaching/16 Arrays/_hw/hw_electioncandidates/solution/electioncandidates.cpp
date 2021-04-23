
#include <iostream>
#include <iomanip>
#include <string>

using namespace std;

int sumVotes(int list[], int size)
{
    int sum = 0;
    
    for (int i = 0; i < size; ++i)
    {
        sum = sum + list[i];
    }
    
    return sum;
}

int winnerIndex(int list[], int size)
{
    int iWin = 0;
    
    for (int i = 0; i < size; ++i)
    {
        if (list[i] > list[iWin])
        {
            iWin = i;
        }
    }

    return iWin;
}


int main()
{
    const int NUM_CANDIDATES = 5;
    
    string candidates[NUM_CANDIDATES];
    int votes[NUM_CANDIDATES] = {};
    
    const int INDENT = 21;
    cout << right;      // right justify setw()
    for (int i = 0; i < NUM_CANDIDATES; i++)
    {
        cout << setw(INDENT) << (to_string(i + 1) + ") Candidate's name: ");
        cin >> candidates[i];
        
        cout << setw(INDENT) << "votes received: ";
        cin >> votes[i];
    }
    cout << endl;
    
    int totalVotes = sumVotes(votes, NUM_CANDIDATES);

    cout << left;      // left justify setw()
    cout << fixed << showpoint << setprecision(2);
    cout << setw(INDENT) << "Candidate" <<
            setw(INDENT) << "Votes Received" <<
            setw(INDENT) << "% of Total Votes" << endl;
    
    for (int i = 0; i < NUM_CANDIDATES; i++)
    {
        string name = candidates[i];
        float perc = (float) votes[i]/totalVotes*100;
        cout << setw(INDENT) << name <<
                setw(INDENT) << votes[i] <<
                setw(INDENT) << perc << endl;
    }
    cout << setw(INDENT) << "Total:"  << totalVotes << endl;
    cout << endl;
    
    int iWinner = winnerIndex(votes, NUM_CANDIDATES);
    cout << "The Winner of the Election is " << candidates[iWinner] << endl;
    
    return 0;
}


