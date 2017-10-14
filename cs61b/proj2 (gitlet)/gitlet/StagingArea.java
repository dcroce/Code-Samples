package gitlet;
import java.io.FileNotFoundException;
import java.io.Serializable;
import java.util.HashMap;
import java.util.HashSet;

/**
 * Created by kyoung on 7/14/17.
 */
public class StagingArea implements Serializable {

    //Fields
    private HashMap<String, String> current; // Name to ID
    private HashSet<String> toBeRemoved;
    private HashMap<String, String> idToName;
    private HashMap<String, String> staged;

    //Constructor
    public StagingArea() {
        current = new HashMap<>();
        toBeRemoved = new HashSet<>();
        idToName = new HashMap<>();
        staged = new HashMap<>();
    }

    //Methods
    public Blob add(String fileName) throws FileNotFoundException {
        Blob blob = new Blob(fileName);
        String id = blob.getId();
        if (idToName.containsKey(id) && idToName.get(id).equals(fileName)) {
            return null;
        }
        idToName.put(id, fileName);
        staged.put(fileName, id);
        return blob;
    }

    public void commit(String message) {
        //create Commit
        //commits current to repo and clears current
    }

    public void remove(String name) {
        toBeRemoved.add(name);
        staged.remove(name);
    }

    public void unstage(String name) {
        current.remove(name);
        staged.remove(name);
    }

    public void clear() {
        staged = new HashMap<>();
        toBeRemoved = new HashSet<>();
    }

    public void unremove(String name) {
        toBeRemoved.remove(name);
    }

    public void setStaged(HashMap<String, String> staged) {
        this.staged = staged;
    }

    public void setCurrent(HashMap<String, String> current) {
        this.current = current;
    }

    public void addToStage(String name, String id) {
        staged.put(name, id);
    }

    //Getter
    public HashMap<String, String> getCurrent() {
        return current;
    }

    public HashSet<String> getToBeRemoved() {
        return toBeRemoved;
    }

    public HashMap<String, String> getIdToName() {
        return idToName;
    }

    public HashMap<String, String> getStaged() {
        return staged;
    }
}
