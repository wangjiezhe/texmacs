
/******************************************************************************
* MODULE     : minimal.cpp
* DESCRIPTION: Minimal example of a plugin
* COPYRIGHT  : (C) 2003  Joris van der Hoeven
*******************************************************************************
* This software falls under the GNU general public license version 3 or later.
* It comes WITHOUT ANY WARRANTY WHATSOEVER. For details, see the file LICENSE
* in the root directory or <http://www.gnu.org/licenses/gpl-3.0.html>.
******************************************************************************/

#include <iostream>
using namespace std;

#define DATA_BEGIN   ((char) 2)
#define DATA_END     ((char) 5)
#define DATA_ESCAPE  ((char) 27)

int
main () {
  cout << DATA_BEGIN << "verbatim:";
  cout << "Hi there!";
  cout << DATA_END;
  cout.flush ();

  while (true) {
    char buffer[100];
    cin.getline (buffer, 100, '\n');
    cout << DATA_BEGIN << "verbatim:";
    cout << "You typed " << buffer;
    cout << DATA_END;
    cout.flush ();
  }
  return 0;
}
