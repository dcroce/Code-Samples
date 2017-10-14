package gitlet;


/** Driver class for Gitlet, the tiny stupid version-control system.
 *  @author
 */
public class Main {

    /** Usage: java gitlet.Main ARGS, where ARGS contains
     *  <COMMAND> <OPERAND> .... */
    public static void main(String... args) {
        if (args.length == 0) {
            System.out.println("Please enter a command.");
        } else if (args[0].equals("init")) {
            if (args.length == 1) {
                init();
            } else {
                System.out.println("Incorrect operands.");
            }
        } else if (!Command.checkDir()) {
            System.out.println("Not in an initialized gitlet directory.");
        } else if (args[0].equals("status")) {
            if (args.length == 1) {
                status();
            } else {
                System.out.println("Incorrect operands.");
            }
        } else if (args[0].equals("log")) {
            if (args.length == 1) {
                log();
            } else {
                System.out.println("Incorrect operands.");
            }
        } else if (args[0].equals("global-log")) {
            if (args.length == 1) {
                globalLog();
            } else {
                System.out.println("Incorrect operands.");
            }
        } else if (args[0].equals("add")) {
            if (args.length == 2) {
                add(args[1]);
            } else {
                System.out.println("Incorrect operands.");
            }
        } else if (args[0].equals("commit")) {
            if (args.length == 2) {
                commit(args[1]);
            } else {
                System.out.println("Incorrect operands.");
            }
        } else if (args[0].equals("rm")) {
            if (args.length == 2) {
                rm(args[1]);
            } else {
                System.out.println("Incorrect operands.");
            }
        } else if (args[0].equals("checkout")) {
            if (args.length == 2) {
                checkoutBranch(args[1]);
            } else if (args.length == 3 && args[1].equals("--")) {
                checkout(args[2]);
            } else if (args.length == 4 && args[2].equals("--")) {
                checkout(args[1], args[3]);
            } else {
                System.out.println("Incorrect operands.");
            }
        } else if (args[0].equals("find")) {
            if (args.length == 2) {
                find(args[1]);
            } else {
                System.out.println("Incorrect operands.");
            }
        } else if (args[0].equals("branch")) {
            if (args.length == 2) {
                branch(args[1]);
            } else {
                System.out.println("Incorrect operands.");
            }
        } else if (args[0].equals("rm-branch")) {
            if (args.length == 2) {
                rmBranch(args[1]);
            } else {
                System.out.println("Incorrect operands.");
            }
        } else if (args[0].equals("reset")) {
            if (args.length == 2) {
                reset(args[1]);
            } else {
                System.out.println("Incorrect operands.");
            }
        } else if (args[0].equals("merge")) {
            if (args.length == 2) {
                merge(args[1]);
            } else {
                System.out.println("Incorrect operands.");
            }
        } else {
            System.out.println("No command with that name exists.");
        }
    }


    //Methods
    public static void init() {
        Command.init();
    }

    public static void add(String name) {
        Command.add(name);
    }

    public static void commit(String message) {
        Command.commit(message);
    }

    public static void rm(String name) {
        //To-do
            //untrack file (remove it from next commit)
            //if file staged, unstage
                //else, remove from working directory
        //Failure
            //if neither staged nor tracked, print error msg
        Command.rm(name);
    }

    public static void log() {
        //To-do
            //display info about each commit backwards starting from head
        Command.log();
    }

    public static void globalLog() {
        //To-do
            //displays all commits
        Command.globalLog();
    }

    public static void find(String message) {
        //To-do
            //print out all commits with given message
        //Failure
            //if no commit, print error msg
        Command.find(message);
    }

    public static void status() {
        //To-do
            //display current branches and staged files and marked for untracking
        Command.status();
    }

    public static void checkout(String name) {
        //To-do
            //see spec
        Command.checkout(name);
    }

    public static void checkoutBranch(String name) {
        Command.checkoutBranch(name);
    }

    public static void checkout(String id, String name) {
        Command.checkout(id, name);
    }

    public static void branch(String name) {
        //To-do
            //create branch and point at current head node
        Command.branch(name);
    }

    public static void rmBranch(String name) {
        //To-do
            //delete branch
        Command.rmBranch(name);

    }

    public static void reset(String commit) {
        //To-do
            //check out all files tracked by given commit (see spec)
        Command.reset(commit);
    }

    public static void merge(String branch) {
        //To-do
            //merge given branch into current branch
        Command.merge(branch);
    }
}
