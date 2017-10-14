import java.util.ArrayList;
import java.util.PriorityQueue;

/**
 * Created by dominiccroce on 7/31/17.
 */
public class TST {

    Node root;
    ArrayList<String> word = new ArrayList<>();
    boolean found = false;

    public TST() {
        this.root = new Node();
    }

    /*
    inserts term with corresponding value into TST
    implementation:
    start at root and iterate down TST only counting when creating a new node
        or going down the middle path
    add each node check if max value is less than weight and update accordingly
    at last char, check that value of node is -1 as initialized
    if it is, replace that with the weight
    runtime:
    O(L) where L is the length of the term because in the worst case,
        traversing the depth of the TST would take logarithmic time which
        increases lower than L since we potentially have to insert L nodes
     */
    public void insert(String term, double weight) {
        Node curr = root;
        int count = 0;
        while (count < term.length()) {
            if (weight > curr.max) {
                curr.max = weight;
            }
            if (curr.item == null) {
                curr.item = term.charAt(count);
                if (count == term.length() - 1) {
                    curr.val = weight;
                    break;
                }
                curr.middle = new Node();
                curr = curr.middle;
                count++;
            } else if (curr.item.equals(term.charAt(count))) {
                if (count == term.length() - 1) {
                    if (curr.val != -1) {
                        throw new IllegalArgumentException("Already inserted");
                    }
                    curr.val = weight;
                    break;
                }
                if (curr.middle == null) {
                    curr.middle = new Node();
                }
                curr = curr.middle;
                count++;
            } else if (curr.item > term.charAt(count)) {
                if (curr.left == null) {
                    curr.left = new Node();
                }
                curr = curr.left;
            } else if (curr.item < term.charAt(count)) {
                if (curr.right == null) {
                    curr.right = new Node();
                }
                curr = curr.right;
            }
        }
    }

    /*
    finds the value of the given term
    implementation:
    same as insert but altered to return val when last character in string is found
    runtime:
    O(L) where L is the length of the term because same traversal as insert
     */
    public double findVal(String term) {
        Node curr = root;
        int count = 0;
        while (count < term.length()) {
            if (curr.item == null) {
                return 0.0;
            } else if (curr.item.equals(term.charAt(count))) {
                if (count == term.length() - 1) {
                    if (curr.val == -1) {
                        return 0.0;
                    } else {
                        return curr.val;
                    }
                }
                if (curr.middle == null) {
                    return 0.0;
                }
                curr = curr.middle;
                count++;
            } else if (curr.item > term.charAt(count)) {
                if (curr.left == null) {
                    return 0.0;
                }
                curr = curr.left;
            } else if (curr.item < term.charAt(count)) {
                if (curr.right == null) {
                    return 0.0;
                }
                curr = curr.right;
            }
        }
        return 0.0;
    }

    /*
    find the node of the last character of the given prefix
    implementation:
    same traversal as insert and findVal except return node when last character is found
    runtime:
    O(L) where L is the length of the term because same traversal as insert and findVal
     */
    public Node findPrefix(String prefix) {
        Node curr = root;
        int count = 0;
        while (count < prefix.length()) {
            if (curr.item == null) {
                return null;
            } else if (curr.item.equals(prefix.charAt(count))) {
                if (count == prefix.length() - 1) {
                    return curr;
                }
                if (curr.middle == null) {
                    return null;
                }
                curr = curr.middle;
                count++;
            } else if (curr.item > prefix.charAt(count)) {
                if (curr.left == null) {
                    return null;
                }
                curr = curr.left;
            } else if (curr.item < prefix.charAt(count)) {
                if (curr.right == null) {
                    return null;
                }
                curr = curr.right;
            }
        }
        return curr;
    }

    /*
    updates the word property of the TST when finding a word based on value
    implementation:
    recursively iterates through tree to find node with correct value
    updates word property when that node is found
    runtime:
    theta(N) where N is the number of nodes in TST because we recursively call the function
        on every node in the TST
     */
    public void wordHelper(String soFar, Node node, double value) {
        if (node.val == value && !this.word.contains(soFar)) {
            this.word.add(soFar);
            this.found = true;
            return;
        }
        Node[] children = new Node[3];
        children[1] = node.left;
        children[0] = node.middle;
        children[2] = node.right;
        int count = 0;
        for (Node child : children) {
            count++;
            if (child != null && node.max >= value && !this.found) {
                if (count == 1) {
                    if (soFar.isEmpty()) {
                        wordHelper(soFar + node.item + child.item, child, value);
                    } else {
                        wordHelper(soFar + child.item, child, value);
                    }
                } else if (soFar.length() > 0) {
                    wordHelper(soFar.substring(0, soFar.length() - 1) + child.item, child, value);
                } else {
                    wordHelper(soFar + child.item, child, value);
                }
            }
        }
    }

    /*
    finds k top values with given prefix
    implementation:
    create priority queue of top values found so far and another one of nodes based on max
    find the prefix node and check edge cases
    add prefix to queue and iterate while queue is not empty
    for each popped node, add children to priority queue and add to topVals if it has a value
    check that the queue of nodes does not contain a node that has a max that is greater than
        the kth top val in topVals
    return top k values from topVals
    runtime:
    O(Np) where Np is number of prefix matches because in the worst case, the function would
        return all prefix matches
     */
    public ArrayList<Double> findTopVals(String prefix, int k) {
        ArrayList<Double> topVals = new ArrayList<>();
        PriorityQueue<Node> queue =
                new PriorityQueue<Node>((n1, n2) -> -Double.compare(n1.max, n2.max));
        Node prefixNode = findPrefix(prefix);
        if (prefixNode == null) {
            return new ArrayList<>();
        } else if (prefixNode.middle == null) {
            topVals.add(prefixNode.val);
            return topVals;
        } else if (prefixNode.val != -1) {
            topVals.add(prefixNode.val);
        }
        if (prefix.isEmpty()) {
            queue.add(prefixNode);
        } else {
            queue.add(prefixNode.middle);
        }
        while (!queue.isEmpty()) {
            Node curr = queue.poll();
            if (topVals.size() >= k && curr.max < topVals.get(k - 1)) {
                break;
            }
            if (curr.val != -1) {
                topVals.add(curr.val);
                topVals.sort((n1, n2) -> -Double.compare(n1, n2));
                if (topVals.size() == k + 1) {
                    topVals.remove(k);
                }
            }
            if (curr.left != null) {
                queue.add(curr.left);
            }
            if (curr.right != null) {
                queue.add(curr.right);
            }
            if (curr.middle != null) {
                queue.add(curr.middle);
            }
        }
        return topVals;
    }


    class Node {
        Node right, left, middle;
        Character item;
        double max, val;

        Node() {
            this.right = null;
            this.left = null;
            this.middle = null;
            this.max = 0;
            this.val = -1;
        }
    }
}
