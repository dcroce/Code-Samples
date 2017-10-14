package gitlet;
import java.io.*;
import java.io.File;
import java.util.*;

/**
 * Created by kyoung on 7/14/17.
 */
public class Command {

    public static boolean checkDir() {
        HashSet<String> files = new HashSet<>();
        for (File file : new File(System.getProperty("user.dir")).listFiles()) {
            files.add(file.getName());
        }
        if (files.contains(".gitlet")) {
            return true;
        }
        return false;
    }

    public static void init() {
        //To-do
        //creates repo in working directory
        //first commit with no files and message "initial commit"
        //single branch: "master"
        //Failure
        //if already gitlet version in directory, abort
        //print error message

        File path = new File(System.getProperty("user.dir"));
        //check for existing gitlet directory
        for (String item : path.list()) {
            if (item.equals(".gitlet")) {
                System.out.print("A gitlet version-control system already"
                        + " exists in the current directory.");
                System.exit(0);
            }
        }
        File gitletDir = new File(path, ".gitlet");
        File blobDir = new File(gitletDir, "blobs");
        File commitDir = new File(gitletDir, "commits");
        File stageFile = new File(gitletDir, "stage");
        File repoFile = new File(gitletDir, "repo");

        gitletDir.mkdir();
        blobDir.mkdir();
        commitDir.mkdir();


        StagingArea stage = new StagingArea();
        Commit first = new Commit("initial commit", stage);
        //String sha = first.assignHashValue();
        Repo repo = new Repo(first);
        repo.getIdToCommit().put(first.getId(), first.getMessage());

        File commitFile = new File(commitDir, first.getId());

        serialize(stage, stageFile.getPath());
        serialize(first, commitFile.getPath());
        serialize(repo, repoFile.getPath());

    }

    public static void add(String name) {
        //To-do
        //add copy of file from directory to staging area
        //if current file is same as previous commit, do not add
        //Failure
        //if file does not exist, print error "file does not exist."
        StagingArea stage = deserialize(System.getProperty("user.dir") + "/.gitlet/stage");
        if (stage.getToBeRemoved().contains(name)) {
            stage.unremove(name);
            serialize(stage, System.getProperty("user.dir") + "/.gitlet/stage");
            System.exit(0);
        } else {
            Blob blob = null;
            try {
                blob = stage.add(name);
                if (blob == null) {
                    System.exit(0);
                }
                File blobFile = new File(System.getProperty("user.dir")
                        + "/.gitlet/blobs/" + blob.getId());
                Utils.writeContents(blobFile, blob.getFile());
            } catch (FileNotFoundException e) {
                System.out.print("File does not exist.");
            } finally {
                serialize(stage, System.getProperty("user.dir") + "/.gitlet/stage");
            }
        }


    }

    public static void commit(String message) {
        //To-do
        //create new commit (see spec for more detail)
        //Failure
        //if no files staged, print "No changes added to the commit."
        //every commit must have commit message
        if (message.equals("")) {
            System.out.print("Please enter a commit message.");
            System.exit(0);
        }
        Repo repo = deserialize(System.getProperty("user.dir") + "/.gitlet/repo");
        StagingArea stage = deserialize(System.getProperty("user.dir") + "/.gitlet/stage");
        if (stage.getStaged().isEmpty() && stage.getToBeRemoved().isEmpty()) {
            System.out.print("No changes added to the commit.");
            serialize(stage, System.getProperty("user.dir") + "/.gitlet/stage");
            serialize(repo, System.getProperty("user.dir") + "/.gitlet/repo");
            System.exit(0);
        }
        Commit commit = new Commit(message, stage);
        repo.commit(commit);
        //serialize commit, repo, stage
        File commitFile = new File(System.getProperty("user.dir")
                + "/.gitlet/commits", commit.getId());
        serialize(commit, commitFile.toString());
        serialize(stage, System.getProperty("user.dir") + "/.gitlet/stage");
        serialize(repo, System.getProperty("user.dir") + "/.gitlet/repo");
    }

    public static void rm(String name) {
        //To-do
        //untrack file (remove it from next commit)
        //if file staged, unstage
        //else, remove from working directory
        //Failure
        //if neither staged nor tracked, print error msg
        Repo repo = deserialize(System.getProperty("user.dir") + "/.gitlet/repo");
        StagingArea stage = deserialize(System.getProperty("user.dir") + "/.gitlet/stage");
        Commit mostRecent = deserialize(System.getProperty("user.dir")
                + "/.gitlet/commits/" + repo.getBranches().get(repo.getHead()).getItem());

        // check if filename was in previous commit
        if (stage.getCurrent().containsKey(name)) {
            stage.remove(name);
            //remove from working directory
            File file = new File(System.getProperty("user.dir"), name);
            file.delete();
        } else if (stage.getStaged().keySet().contains(name)) {
            stage.unstage(name);
        } else {
            System.out.print("No reason to remove the file.");
        }
        serialize(stage, System.getProperty("user.dir") + "/.gitlet/stage");
        serialize(repo, System.getProperty("user.dir") + "/.gitlet/repo");
        serialize(mostRecent, System.getProperty("user.dir")
                + "/.gitlet/commits/" + mostRecent.getId());
    }

    public static void log() {
        //To-do
        //display info about each commit backwards starting from head
        Repo repo = deserialize(System.getProperty("user.dir") + "/.gitlet/repo");
        Commit mostRecent = deserialize(System.getProperty("user.dir")
                + "/.gitlet/commits/" + repo.getBranches().get(repo.getHead()).getItem());
        while (!mostRecent.getMessage().equals("initial commit")) {
            repo.printlog(mostRecent);
            String parent = repo.getIdToNode().get(mostRecent.getId()).getParent();
            mostRecent = deserialize(System.getProperty("user.dir")
                    + "/.gitlet/commits/" + parent);
        }
        System.out.println("===");
        System.out.println("Commit " + mostRecent.getId());
        System.out.println(mostRecent.getCommitDate());
        System.out.println(mostRecent.getMessage());
    }

    public static void globalLog() {
        //To-do
        //displays all commits
        Repo repo = deserialize(System.getProperty("user.dir") + "/.gitlet/repo");
        HashSet<String> commitIds = new HashSet<String>(repo.getIdToCommit().keySet());
        HashSet<Commit> commits = new HashSet<>();
        for (String id : commitIds) {
            commits.add(deserialize(System.getProperty("user.dir")
                    + "/.gitlet/commits/" + id));
        }
        repo.printGlobal(commits);
    }

    public static void find(String message) {
        //To-do
        //print out all commits with given message
        //Failure
        //if no commit, print error msg
        Repo repo = deserialize(System.getProperty("user.dir") + "/.gitlet/repo");
        boolean found = false;
        for (String id : repo.getIdToCommit().keySet()) {
            if (repo.getIdToCommit().get(id).equals(message)) {
                System.out.println(id);
                found = true;

            }
        }
        if (!found) {
            System.out.println("Found no commit with that message.");
        }
    }

    public static void status() {
        //To-do
        //display current branches and staged files and marked for untracking
        StagingArea stage = deserialize(System.getProperty("user.dir") + "/.gitlet/stage");
        Repo repo = deserialize(System.getProperty("user.dir") + "/.gitlet/repo");
        TreeSet<String> ordered = new TreeSet<>();
        ordered.addAll(repo.getBranches().keySet());

        System.out.println("=== Branches ===");
        for (String branch : ordered) {
            if (branch.equals(repo.getHead())) {
                System.out.println("*" + branch);
            } else {
                System.out.println(branch);
            }
        }
        System.out.println();
        System.out.println("=== Staged Files ===");
        for (String file : stage.getStaged().keySet()) {
            System.out.println(file);
        }
        System.out.println();
        System.out.println("=== Removed Files ===");
        for (String file : stage.getToBeRemoved()) {
            System.out.println(file);
        }
        System.out.println();
        System.out.println("=== Modifications Not Staged For Commit ===");
        System.out.println();
        System.out.println("=== Untracked Files ===");

        serialize(stage, System.getProperty("user.dir") + "/.gitlet/stage");
        serialize(repo, System.getProperty("user.dir") + "/.gitlet/repo");
    }

    public static void checkout(String name) {
        //To-do
        Repo repo = deserialize(System.getProperty("user.dir") + "/.gitlet/repo");
        Commit mostRecent = deserialize(System.getProperty("user.dir")
                + "/.gitlet/commits/" + repo.getBranches().get(repo.getHead()).getItem());
        StagingArea stage = deserialize(System.getProperty("user.dir") + "/.gitlet/stage");

        String blobId = null;
        for (String id : mostRecent.getContents()) {
            if (stage.getIdToName().get(id).equals(name)) { //find blob id
                blobId = id;
                break;
            }
        }

        if (blobId == null) {
            System.out.print("File does not exist in that commit.");
            System.exit(0);
        }
        byte[] content = Utils.readContents(new File(System.getProperty("user.dir")
                + "/.gitlet/blobs/" + blobId));
        File path = new File(System.getProperty("user.dir"));
        File file = new File(path, name);
        Utils.writeContents(file, content);
    }

    public static void checkoutBranch(String name) {

        Repo repo = deserialize(System.getProperty("user.dir") + "/.gitlet/repo");
        if (!repo.getBranches().containsKey(name)) {
            System.out.println("No such branch exists.");
            System.exit(0);
        } else if (name.equals(repo.getHead())) {
            System.out.println("No need to checkout the current branch.");
            System.exit(0);
        }

        // check most recent commit in specified branch
        Commit givenBranch = deserialize(System.getProperty("user.dir")
                + "/.gitlet/commits/" + repo.getBranches().get(name).getItem());
        // list files in working directory
        File wd = new File(System.getProperty("user.dir"));
        File[] list = wd.listFiles();
        // find file not found in current branch's commit.contents
        Commit currBranch = deserialize(System.getProperty("user.dir")
                + "/.gitlet/commits/" + repo.getBranches().get(repo.getHead()).getItem());
        StagingArea stage = deserialize(System.getProperty("user.dir") + "/.gitlet/stage");
        HashSet<String> currNames = new HashSet<>();
        for (String id : currBranch.getContents()) {
            currNames.add(stage.getIdToName().get(id));
        }
        HashSet<String> givenNames = new HashSet<>();
        for (String id : givenBranch.getContents()) {
            givenNames.add(stage.getIdToName().get(id));
        }
        for (File file : list) {
            if (!stage.getStaged().keySet().contains(file.getName())
                    && !currNames.contains(file.getName())
                    && !stage.getToBeRemoved().contains(file.getName())
                    && !file.getName().contains(".gitlet")) {
                System.out.println("There is an untracked file in the way;"
                        + " delete it or add it first."); //32 is stuck here
                System.exit(0);
            }

        }
        // if that file is in the given branch's commits contents
        // then print error
        // passes error check, then

        for (String names : givenNames) {
            Command.checkout(givenBranch.getId(), names);
        }


        for (String names : currNames) {
            if (!givenNames.contains(names)) {
//                stage.getCurrent().remove(names);
                File file = new File(System.getProperty("user.dir"), names);
                file.delete();
            }
        }
//        String x = "x: ";
//        for (String a : givenBranch.getContents()) {
//            x += stage.getIdToName().get(a) + " ";
//        }
//        if (name.equals("other") && new File(System.getProperty("user.dir"), "g.txt").exists()) {
//            System.out.println(x);
//        }
        HashMap<String, String> futureCurrent = new HashMap<>();
        for (String ids : givenBranch.getContents()) {
            futureCurrent.put(stage.getIdToName().get(ids), ids);
        }
        repo.setHead(name);
        stage.setStaged(new HashMap<String, String>());
        stage.setCurrent(futureCurrent);
        serialize(stage, System.getProperty("user.dir") + "/.gitlet/stage");
        serialize(repo, System.getProperty("user.dir") + "/.gitlet/repo");

    }

    public static void checkout(String id, String name) {
        Repo repo = deserialize(System.getProperty("user.dir") + "/.gitlet/repo");
        HashSet<String> commitIds = new HashSet<String>(repo.getIdToCommit().keySet());
        String myId = null;
        for (String fullId : commitIds) {
            if (fullId.contains(id)) {
                myId = fullId;
                break;
            }
        }
        if (myId == null) {
            System.out.print("No commit with that id exists.");
            System.exit(0);
        }

        Commit thisCommit = deserialize(System.getProperty("user.dir")
                + "/.gitlet/commits/" + myId);
        StagingArea stage = deserialize(System.getProperty("user.dir") + "/.gitlet/stage");

        String blobId = null;
        for (String blob : thisCommit.getContents()) {
            if (stage.getIdToName().get(blob).equals(name)) { //find blob id
                blobId = blob;
                break;
            }
        }

        if (blobId == null) {
            System.out.print("File does not exist in that commit.");
            System.exit(0);
        }
        byte[] content = Utils.readContents(new File(System.getProperty("user.dir")
                + "/.gitlet/blobs/" + blobId));
        File path = new File(System.getProperty("user.dir"));
        File file = new File(path, name);
        Utils.writeContents(file, content);

        serialize(stage, System.getProperty("user.dir") + "/.gitlet/stage");
        serialize(repo, System.getProperty("user.dir") + "/.gitlet/repo");
    }


    public static void branch(String name) {
        //To-do
        //create branch and point at current head node
        Repo repo = deserialize(System.getProperty("user.dir") + "/.gitlet/repo");
        repo.addBranch(name);
        serialize(repo, System.getProperty("user.dir") + "/.gitlet/repo");
    }

    public static void rmBranch(String name) {
        //To-do
        //delete branch
        Repo repo = deserialize(System.getProperty("user.dir") + "/.gitlet/repo");
        repo.removeBranch(name);
        serialize(repo, System.getProperty("user.dir") + "/.gitlet/repo");

    }

    public static void reset(String commit) {
        //To-do
        //check out all files tracked by given commit (see spec)
        Repo repo = deserialize(System.getProperty("user.dir") + "/.gitlet/repo");
        StagingArea stage = deserialize(System.getProperty("user.dir") + "/.gitlet/stage");
        HashSet<String> commitIds = new HashSet<String>(repo.getIdToCommit().keySet());
        String myId = null;
        for (String fullId : commitIds) {
            if (fullId.contains(commit)) {
                myId = fullId;
                break;
            }
        }
        if (myId == null) {
            System.out.print("No commit with that id exists.");
            System.exit(0);
        }
        Commit givenCommit = deserialize(System.getProperty("user.dir")
                + "/.gitlet/commits/" + myId);
        Commit currCommit = deserialize(System.getProperty("user.dir")
                + "/.gitlet/commits/" + repo.getBranches().get(repo.getHead()).getItem());

        HashSet<String> fileNames = new HashSet<>();
        for (String blobs : givenCommit.getContents()) {
            fileNames.add(stage.getIdToName().get(blobs));
        }
        HashSet<String> currFileNames = new HashSet<>();
        for (String blobs : currCommit.getContents()) {
            currFileNames.add(stage.getIdToName().get(blobs));
        }
        HashSet<String> wd = new HashSet<>();
        for (File file : new File(System.getProperty("user.dir")).listFiles()) {
            wd.add(file.getName());
        }
        for (String wdNames : wd) {
            if (!stage.getCurrent().keySet().contains(wdNames)
                    && !stage.getStaged().keySet().contains(wdNames)
                    && !stage.getToBeRemoved().contains(wdNames)
                    && !wdNames.contains(".gitlet")) {
                System.out.println("There is an untracked file in the way;"
                        + " delete it or add it first.");
                System.exit(0);
            }
        }

        for (String files : fileNames) {
            checkout(commit, files);
        }
        for (String names : currFileNames) {
            if (!fileNames.contains(names)) {
                rm(names);
            }
        }
        repo.getBranches().put(repo.getHead(), repo.getIdToNode().get(myId));
        for (String clearedNames : stage.getStaged().keySet()) {
            File file = new File(System.getProperty("user.dir"), clearedNames);
            file.delete();
        }
        stage.clear();
        serialize(stage, System.getProperty("user.dir") + "/.gitlet/stage");
        serialize(repo, System.getProperty("user.dir") + "/.gitlet/repo");

    }

    public static void merge(String branch) {
        Repo repo = deserialize(System.getProperty("user.dir") + "/.gitlet/repo");
        StagingArea stage = deserialize(System.getProperty("user.dir") + "/.gitlet/stage");
        if (!stage.getStaged().isEmpty() || !stage.getToBeRemoved().isEmpty()) {
            System.out.println("You have uncommitted changes.");
            System.exit(0);
        } else if (!repo.getBranches().containsKey(branch)) {
            System.out.println("A branch with that name does not exist.");
            System.exit(0);
        } else if (branch.equals(repo.getHead())) {
            System.out.println("Cannot merge a branch with itself.");
            System.exit(0);
        }
        String splitId = repo.findSplit(branch);
        HashMap<String, byte[]> currFiles =
                getFiles(repo.getBranches().get(repo.getHead()).getItem());
        HashMap<String, byte[]> givenFiles = getFiles(repo.getBranches().get(branch).getItem());
        HashMap<String, byte[]> splitFiles = getFiles(splitId);
        HashMap<String, byte[]> wdFiles = getWd();
        HashSet<String> allFiles = getNames(currFiles, givenFiles, splitFiles, wdFiles);
        boolean mergeConflict = false;
        for (String file : allFiles) {
            if (currFiles.containsKey(file)) { // IN current
                if (!givenFiles.containsKey(file) && splitFiles.containsKey(file)) {
                    String curr = new String(currFiles.get(file));
                    String split = new String(splitFiles.get(file));
                    if (!curr.equals(split)) { // different in split and current
//                        System.out.println(1);
                        mergeConflict = mergeConflictHelper(file, branch);
                        continue;
                    } else { // same in split and current
                        rm(file); //remove and untrack file
                    }
                } else if (!givenFiles.containsKey(file) && !splitFiles.containsKey(file)) {
                    continue;
                } else if (givenFiles.containsKey(file) && splitFiles.containsKey(file)) {
                    if (splitFiles.get(file).equals(currFiles.get(file))) {
                        if (currFiles.get(file).equals(givenFiles.get(file))) { // same in all 3
                            continue;
                        } else { // curr and split are same, but different in given
                            checkout(repo.getBranches().get(branch).getItem(), file);
                            stage.addToStage(file,
                                    findId(file, repo.getBranches().get(branch).getItem(), stage));
                        }
                    }
                    String curr = new String(currFiles.get(file));
                    String given = new String(givenFiles.get(file));
                    if (!curr.equals(given)) { //curr is different from split and given
//                        System.out.println(2);
                        mergeConflict = mergeConflictHelper(file, branch);
                        continue;
                    }
                } else if (!splitFiles.containsKey(file) && givenFiles.containsKey(file)) {
                    String given = new String(givenFiles.get(file));
                    String split = new String(splitFiles.get(file));
                    if (!givenFiles.get(file).equals(currFiles.get(file))) {
//                        System.out.println(3);
                        mergeConflict = mergeConflictHelper(file, branch);
                        continue;
                    }
                }
            } else if (givenFiles.containsKey(file)) { // in given but not current
                if (!splitFiles.containsKey(file)) { // only in given
                    checkout(repo.getBranches().get(branch).getItem(), file);
                    stage.addToStage(file,
                            findId(file, repo.getBranches().get(branch).getItem(), stage));
                } else {
                    String split = new String(splitFiles.get(file));
                    String given = new String(givenFiles.get(file));
                    if (!split.equals(given)) { // different in split and given
//                        System.out.println(4);
                        mergeConflict = mergeConflictHelper(file, branch);
                        continue;
                    }
                }
            }
            checkUntracked(file, currFiles, givenFiles, splitFiles, wdFiles);
        } //after iteration through all files
        if (mergeConflict) {
            System.out.println("Encountered a merge conflict.");
            serialize(stage, System.getProperty("user.dir") + "/.gitlet/stage");
            serialize(repo, System.getProperty("user.dir") + "/.gitlet/repo");
        } else { // commit with message
            commit("Merged " + repo.getHead() + " with " + branch + ".");
        }
    }

    public static void checkUntracked(String name, HashMap<String, byte[]> a,
                                      HashMap<String, byte[]> b,
                                      HashMap<String, byte[]> c, HashMap<String, byte[]> d) {
        String aString = "";
        if (a.keySet().contains(name)) {
            aString = new String(a.get(name));
        }
        String bString = "";
        if (b.keySet().contains(name)) {
            bString = new String(b.get(name));
        }
        String dString = "";
        if (d.keySet().contains(name)) {
            dString = new String(d.get(name));
        }
//        if (name.equals("k.txt")) {
//            System.out.println(dString);
//        }
        if (!dString.equals("") && !dString.equals(aString) && !dString.equals(bString)) {
            System.out.println("There is an untracked file in the way; delete it or add it first.");
            System.exit(0);
        }
    }

    public static String findId(String fileName, String commitId, StagingArea stage) {
        Commit commit = deserialize(new File(System.getProperty("user.dir")
                + "/.gitlet/commits", commitId).toString());
        for (String blobId : commit.getContents()) {
            if (fileName.equals(stage.getIdToName().get(blobId))) {
                return blobId;
            }
        }
        return null;
    }

    public static boolean mergeConflictHelper(String fileName, String branch) {
        Repo repo = deserialize(System.getProperty("user.dir") + "/.gitlet/repo");
        StagingArea stage = deserialize(System.getProperty("user.dir") + "/.gitlet/stage");
        String splitId = repo.findSplit(branch);
        HashMap<String, byte[]> currFiles =
                getFiles(repo.getBranches().get(repo.getHead()).getItem());
        HashMap<String, byte[]> givenFiles = getFiles(repo.getBranches().get(branch).getItem());
        HashMap<String, byte[]> splitFiles = getFiles(splitId);
        HashMap<String, byte[]> wdFiles = getWd();
        String curr = null;
        String given = null;

        if (currFiles.containsKey(fileName)) {
            curr = new String(currFiles.get(fileName));
        }
        if (givenFiles.containsKey(fileName)) {
            given = new String(givenFiles.get(fileName));
        }

        String header = "<<<<<<< HEAD\n";
        String middle = "=======\n";
        String footer = ">>>>>>>\n";
        String merged = "";
        if (curr == null) {
            merged = new String(header + middle + given + footer);
        } else if (given == null) {
            merged = new String(header + curr + middle + footer);
        } else {
            merged = new String(header + curr + middle + given + footer);
        }
//        System.out.println(merged);
        Utils.writeContents(new File(System.getProperty("user.dir"), fileName), merged.getBytes());

        return true;
    }

    public static HashMap<String, byte[]> getFiles(String commitId) {
        Repo repo = deserialize(System.getProperty("user.dir") + "/.gitlet/repo");
        StagingArea stage = deserialize(System.getProperty("user.dir") + "/.gitlet/stage");
        Commit commit = deserialize(System.getProperty("user.dir")
                + "/.gitlet/commits/" + commitId);
        HashMap<String, byte[]> files = new HashMap<>();
        for (String blobId : commit.getContents()) {
            byte[] content = Utils.readContents(new File(System.getProperty("user.dir")
                            + "/.gitlet/blobs/" + blobId));
            files.put(stage.getIdToName().get(blobId), content);
        }
        return files;
    }

    public static HashMap<String, byte[]> getWd() {
        HashMap<String, byte[]> files = new HashMap<>();
        for (File file : new File(System.getProperty("user.dir")).listFiles()) {
            String fileName = file.getName();
            if (!fileName.contains(".gitlet")) {
                byte[] content = Utils.readContents(new File(System.getProperty("user.dir"),
                        fileName));
                files.put(fileName, content);
            }
        }
        return files;
    }

    public static HashSet<String> getNames(HashMap<String, byte[]> a, HashMap<String, byte[]> b,
                                           HashMap<String, byte[]> c, HashMap<String, byte[]> d) {
        HashSet<String> names = new HashSet<>();
        for (String name : a.keySet()) {
            names.add(name);
        }
        for (String name : b.keySet()) {
            names.add(name);
        }
        for (String name : c.keySet()) {
            names.add(name);
        }
        for (String name : d.keySet()) {
            names.add(name);
        }
        return names;
    }

    public static void serialize(Object o, String path) {
        try {
            FileOutputStream file = new FileOutputStream(path);
            ObjectOutputStream out = new ObjectOutputStream(file);
            out.writeObject(o);
            file.close();
            out.close();
        } catch (IOException i) {
            i.printStackTrace();
        }
    }

    public static <T> T deserialize(String path) {
        T o = null;
        try {
            FileInputStream file = new FileInputStream(path);
            ObjectInputStream in = new ObjectInputStream(file);
            o = (T) in.readObject();
            in.close();
            file.close();
            return o;
        } catch (IOException i) {
            i.printStackTrace();
            return o;
        } catch (ClassNotFoundException e) {
            e.printStackTrace();
            return o;
        }
    }

}
