package gitlet;
import java.io.Serializable;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.HashSet;

/**
 * Created by kyoung on 7/14/17.
 */
public class Commit implements Serializable {

    //Fields
    private String message;
    private String commitDate;
    private HashSet<String> contents;
    private String id;

    //Constructor
    public Commit(String message, StagingArea stage) {
        this.message = message;
        LocalDateTime now =  LocalDateTime.now();
        commitDate = now.format(DateTimeFormatter.ISO_DATE) + " "
                + now.format(DateTimeFormatter.ISO_TIME);
        commitDate = commitDate.substring(0, 19);
        contents = new HashSet<>();
        for (String name : stage.getStaged().keySet()) {
            stage.getCurrent().put(name, stage.getStaged().get(name));
            contents.add(stage.getStaged().get(name));
        }
        for (String name : stage.getToBeRemoved()) {
            stage.getCurrent().remove(name);
        }
        for (String name : stage.getCurrent().keySet()) {
            if (!stage.getToBeRemoved().contains(name)
                    && !stage.getStaged().keySet().contains(name)) {
                contents.add(stage.getCurrent().get(name)); //adds the hash ID of current
            }
        }
        id = this.assignHashValue();
        stage.clear();
    }

    //Getters
    public String getMessage() {
        return message;
    }

    public String getCommitDate() {
        return commitDate;
    }

    public HashSet<String> getContents() {
        return contents;
    }

    public String getId() {
        return id;
    }

    //Methods
    public String assignHashValue() {
        return Utils.sha1(this.message + this.commitDate);
    }
}
