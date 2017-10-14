import java.util.Comparator;
import java.util.TreeMap;

/**
 * Prefix-Trie. Supports linear time find() and insert().
 * Should support determining whether a word is a full word in the
 * Trie or a prefix.
 *
 * @author
 */
public class Trie {
    private Node root;

    public Trie() {
        root = new Node(null);
    }

    public Trie(Comparator<Character> comparator) {
        root = new Node(comparator);
    }

    /*
    find whether the string is in the tree
    if isFullWord is false, then partial prefix will return true
    else, then only full word matches will return true
    implementation:
    iterates through each character and determines if it exists in links
    if it doesn't, then return false
    if it does, then continue and check condition and isFullWord
    runtime:
    O(L) where L is length of string because we iterate through the length of the string
    if there's a miss on the first character, it would be constant time
     */
    public boolean find(String s, boolean isFullWord) {
        if (s == null || s.equals("")) {
            throw new IllegalArgumentException("string is null or empty");
        } else {
            Node curr = root;
            for (int i = 0; i < s.length(); i++) {
                Character c = s.charAt(i);
                if (!curr.links.containsKey(c)) {
                    return false;
                }
                curr = curr.links.get(c);
            }
            if (!isFullWord || curr.exists) {
                return true;
            }
            return false;
        }
    }

    /*
    inserts a string into the trie
    implementation:
    iterates through the length of the string
    if links does not contain the current character, create a new node and add to links
    once iterated through completely, set final node's exists = true
    runtime:
    theta(L) where L is length of string
        because the function iterates through the length of the string
     */
    public void insert(String s) {
        if (s == null || s.equals("")) {
            throw new IllegalArgumentException("string is null or empty");
        } else {
            Node curr = root;
            for (int i = 0; i < s.length(); i++) {
                Character c = s.charAt(i);
                if (!curr.links.containsKey(c)) {
                    Node newChar = new Node((Comparator<Character>) curr.links.comparator());
                    curr.links.put(c, newChar);
                }
                curr = curr.links.get(c);
                if (i == s.length() - 1) {
                    curr.setExists(true);
                }
            }
        }
    }

    /*
    helper method for AlphabetSort
    prints all words in given trie
    implementation:
    recursively adds characters to soFar
    prints if node's exist property is true
    recursively calls all children
    runtime:
    theta(N) where N is the number of nodes
        because the function iterates through all the nodes' children
     */
    public void printTrie(String soFar, Node node) {
        if (node.exists) {
            System.out.println(soFar);
        }
        for (Character child : node.links.keySet()) {
            printTrie(soFar + child, node.links.get(child));
        }


    }

    public Node getRoot() {
        return root;
    }

    /*
    Node subclass for Trie
    indicates if node is last character in a full word
    links is a tree map of where the key is the character
        and node is the corresponding node to the character for all chidlren
     */
    private class Node {
        boolean exists;
        TreeMap<Character, Node> links;
        Node(Comparator<Character> comparator) {
            links = new TreeMap<Character, Node>(comparator);
        }

        void setExists(boolean exists) {
            this.exists = exists;
        }
    }
}
