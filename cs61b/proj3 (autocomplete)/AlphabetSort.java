import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.util.HashMap;

/**
 * AlphabetSort takes input from stdin and prints to stdout.
 * The first line of input is the alphabet permutation.
 * The the remaining lines are the words to be sorted.
 * 
 * The output should be the sorted words, each on its own line, 
 * printed to std out.
 */
public class AlphabetSort {

    /**
     * Reads input from standard input and prints out the input words in
     * alphabetical order.
     *
     * @param args ignored
     *
     */
    /*
    implementation:
    use BufferReader and InputStreamReader to read incoming file
    read first line and check error case for no alphabet
    creates a HashMap where key is the char in the alphabet
        and value is what position it is indexed
    create a new Trie with a comparator that compares values
    check if there are words
    iterate through all the lines, adding them to the trie
    then call printTrie starting from root to get words in order of given alphabet
    runtime:
    O(MN) where N is number of words and M is number of characters in a word because
        the nested while for loop is runtime determining factor which iterates through
        each word and each character per word
    if there is no alphabet, it would run in constant time
     */
    public static void main(String[] args) {
        BufferedReader in
                = new BufferedReader(new InputStreamReader(System.in));
        try {
            String alpha = in.readLine();
            if (alpha == null) {
                throw new IllegalArgumentException("No alphabet or words");
            }
            HashMap<Character, Integer> chars = new HashMap<>();
            for (int i = 0; i < alpha.length(); i++) {
                if (chars.containsKey(alpha.charAt(i))) {
                    throw new IllegalArgumentException("Duplicate in alphabet");
                } else {
                    chars.put(alpha.charAt(i), i);
                }
            }
            Trie trie = new Trie((c1, c2) -> chars.get(c1).compareTo(chars.get(c2)));
            String line = in.readLine();
            if (line == null) {
                throw new IllegalArgumentException("No words");
            }
            while (line != null) {
                for (int i = 0; i < line.length(); i++) {
                    if (!chars.containsKey(line.charAt(i))) {
                        line = "";
                        break;
                    }
                }
                if (!line.equals("")) {
                    trie.insert(line);
                }
                line = in.readLine();
            }
            trie.printTrie("", trie.getRoot());
        } catch (IOException e) {
            e.printStackTrace();
        }
    }
}
