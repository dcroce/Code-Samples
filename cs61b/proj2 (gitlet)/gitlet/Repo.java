package gitlet;
import java.io.Serializable;
import java.util.HashMap;
import java.util.HashSet;

/**
 * Created by kyoung on 7/14/17.
 */
public class Repo implements Serializable {

    //Fields
    private String head; //points to current branch
    private HashMap<String, Node> branches = new HashMap<>();
    private HashMap<String, String> idToCommit = new HashMap<>();
    private HashMap<String, Node> idToNode = new HashMap<>();

    //Constructor
    public Repo(Commit initial) {
        Node firstNode = new Node(initial.getId(), null);
        String branch = "master";
        branches.put(branch, firstNode);
        head = branch;
        idToNode.put(firstNode.item, firstNode);
    }

    //Methods

    public String getHead() {
        return head;
    }

    public HashMap<String, Node> getBranches() {
        return branches;
    }

    public HashMap<String, String> getIdToCommit() {
        return idToCommit;
    }

    public HashMap<String, Node> getIdToNode() {
        return idToNode;
    }

    public void moveHead(String hashValue) {

    }

    public void find(String message) {

    }

    public void printGlobal(HashSet<Commit> commits) {
        for (Commit c : commits) {
            printlog(c);
        }
    }

    public void printlog(Commit c) {
        System.out.println("===");
        System.out.println("Commit " + c.getId());
        System.out.println(c.getCommitDate());
        System.out.println(c.getMessage());
        System.out.println();
    }

    public void addBranch(String name) {
        if (branches.keySet().contains(name)) {
            System.out.print("A branch with that name already exists.");
            System.exit(0);
        }
        Node current = branches.get(head);
        branches.put(name, current);
    }

    public void removeBranch(String name) {
        if (!branches.keySet().contains(name)) {
            System.out.print("A branch with that name does not exist.");
            System.exit(0);
        } else if (name.equals(head)) {
            System.out.print("Cannot remove the current branch.");
            System.exit(0);
        } else {
            branches.remove(name);
        }
    }

    public void commit(Commit toCommit) {
        String id = toCommit.getId();
        idToCommit.put(id, toCommit.getMessage());
        Node newNode = new Node(id, branches.get(head).getItem());
        branches.replace(head, newNode);
        idToNode.put(id, newNode);
    }

    public void setHead(String head) {
        this.head = head;
    }

    public String findSplit(String branch) {
        HashSet<String> currCommits = new HashSet<>();
        Node pointer = branches.get(head);
        String givenId = branches.get(branch).item;
        String splitId = null;
        while (pointer != null) {
            if (pointer.item.equals(givenId)) {
                System.out.println("Given branch is an ancestor of the current branch.");
                System.exit(0);
            } else {
                currCommits.add(pointer.item);
                pointer = idToNode.get(pointer.getParent());
            }
        }
        pointer = branches.get(branch);
        while (pointer != null) {
            if (currCommits.contains(pointer.item)) {
                if (pointer.item.equals(branches.get(head).item)) {
                    branches.put(head, pointer);
                    System.out.println("Current branch fast-forwarded.");
                    System.exit(0);
                } else {
                    splitId = pointer.item;
                    return splitId;
                }
            }
            pointer = idToNode.get(pointer.getParent());
        }
        return splitId;
    }

    //Subclass
    public class Node implements Serializable {

        //Fields
        private String item;
        private String parent;

        //Constructor
        public Node(String item, String parent) {
            this.item = item;
            this.parent = parent;
        }

        //Getters
        public String getItem() {
            return item;
        }

        public String getParent() {
            return parent;
        }


    }
}
