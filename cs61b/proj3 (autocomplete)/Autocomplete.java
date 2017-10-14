import java.util.ArrayList;

/**
 * Implements autocomplete on prefixes for a given dictionary of terms and weights.
 *
 * @author
 */
public class Autocomplete {

    TST tree;

    /**
     * Initializes required data structures from parallel arrays.
     *
     * @param terms Array of terms.
     * @param weights Array of weights.
     */
    /*
    implementation:
    for loop through the terms and insert them to the TST
    runtime:
    O(MN) where N is number of terms and M is max length of terms because we iterate through
        number terms and insert all of them which takes M time.
     */
    public Autocomplete(String[] terms, double[] weights) {
        this.tree = new TST();
        if (terms.length != weights.length) {
            throw new IllegalArgumentException("Non equal lengths");
        }
        for (int i = 0; i < weights.length; i++) {
            if (weights[i] < 0) {
                throw new IllegalArgumentException("Negative weights");
            }
            tree.insert(terms[i], weights[i]);
        }

    }

    /**
     * Find the weight of a given term. If it is not in the dictionary, return 0.0
     *
     * @param term
     * @return
     */
    /*
    see findVal in TST.java because it just returns findVal
     */
    public double weightOf(String term) {
        return tree.findVal(term);
    }

    /**
     * Return the top match for given prefix, or null if there is no matching term.
     * @param prefix Input prefix to match against.
     * @return Best (highest weight) matching string in the dictionary.
     */
    /*
    see topMatches
     */
    public String topMatch(String prefix) {
        ArrayList<String> top = (ArrayList<String>) topMatches(prefix, 1);
        return top.get(0);
    }

    /**
     * Returns the top k matching terms (in descending order of weight) as an iterable.
     * If there are less than k matches, return all the matching terms.
     *
     * @param prefix
     * @param k
     * @return
     */
    /*
    implementation:
    checks if k is valid
    finds the top k values of the given prefix
    finds the starting node of prefix
    for the values in top values, use wordHelper to find word corresponding the value
    return the words
    runtime:
    theta(N) where N is the number of nodes in the TST because the rate
        determining factor is word helper which has the same runtime
         
     */
    public Iterable<String> topMatches(String prefix, int k) {
        if (k <= 0) {
            throw new IllegalArgumentException("k is negative");
        }
        ArrayList<Double> topVals = tree.findTopVals(prefix, k);
        ArrayList<String> matches = new ArrayList<>();
        TST.Node start = null;
        if (prefix.isEmpty()) {
            start = tree.root;
        } else {
            start = tree.findPrefix(prefix);
        }
        if (start == null) {
            return matches;
        }
        double prevVal = topVals.get(0);
        for (Double val : topVals) {
            if (val == null) {
                break;
            }
            if (prevVal != val) {
                tree.word.clear();
            }
            tree.found = false;
            tree.wordHelper(prefix, start, val);
            int i = 0;
            while (matches.contains(tree.word.get(i))) {
                i++;
            }
            matches.add(tree.word.get(i));
            prevVal = val;
        }
        tree.found = false;
        tree.word.clear();
        return matches;
    }

    /**
     * Test client. Reads the data from the file, then repeatedly reads autocomplete
     * queries from standard input and prints out the top k matching terms.
     *
     * @param args takes the name of an input file and an integer k as
     *             command-line arguments
     */
    public static void main(String[] args) {
        // initialize autocomplete data structure
        In in = new In(args[0]);
        int N = in.readInt();
        String[] terms = new String[N];
        double[] weights = new double[N];
        for (int i = 0; i < N; i++) {
            weights[i] = in.readDouble();   // read the next weight
            in.readChar();                  // scan past the tab
            terms[i] = in.readLine();       // read the next term
        }

        Autocomplete autocomplete = new Autocomplete(terms, weights);

        // process queries from standard input
        int k = Integer.parseInt(args[1]);
        while (StdIn.hasNextLine()) {
            String prefix = StdIn.readLine();
            for (String term : autocomplete.topMatches(prefix, k)) {
                StdOut.printf("%14.1f  %s\n", autocomplete.weightOf(term), term);
            }
        }
    }
}
