package hmi;

import java.util.Scanner;
import com.modeliosoft.modelio.javadesigner.annotations.objid;
import controller.Controller;
import hmi.console.LevelView;
import hmi.levels.Level1;
import hmi.levels.Level2;
import hmi.levels.Level3;
import hmi.levels.Level4;
import hmi.levels.Level5;

@objid ("2b78cfa7-5c54-4351-978d-0c670bd39bb3")
public class Console {
    @objid ("54c064d1-8800-4cd8-a9bb-2aedfacab191")
    public static void main(String[] args) {
        Controller controller;
        
        try {
            controller = new Controller(Level1.buildFromString());
        } catch (Exception e) {
            e.printStackTrace();
            return;
        }
        
        Scanner scanner = new Scanner(System.in);
        
        int levelChoice = 0;
        while (levelChoice < 1 || levelChoice > 5) {
            System.out.println("Select a level between 1 and 5 (both included):");
            try {
                levelChoice = Integer.parseInt(scanner.nextLine());
            } catch (NumberFormatException e) {
                System.out.println("Invalid entry. Select a level between 1 and 5 (both included):");
            }
        }
        
        try {
            switch (levelChoice) {
            case 1:
                controller.setLevel(Level1.buildFromString());
                break;
            case 2:
                controller.setLevel(Level2.buildFromString());
                break;
            case 3:
                controller.setLevel(Level3.buildFromString());
                break;
            case 4:
                controller.setLevel(Level4.buildFromString());
                break;
            case 5:
                controller.setLevel(Level5.buildFromString());
                break;
            default:
                scanner.close();
                throw new IllegalArgumentException("This should not happen... But levelChoice is too high.");
            }
        } catch (Exception e) {
            e.printStackTrace();
        
            scanner.close();
            return;
        }
        
        String actions;
        System.out.println(
                "Choose (udrl for up, down, right, left) or 'quit' to leave or 'help' to see solution from start:");
        while (true) {
            System.out.println(LevelView.view(controller.getLevel()));
            if (controller.checkVictory()) {
                System.out.println("You won!");
                break;
            }
        
            System.out.print("Actions: ");
            actions = scanner.nextLine();
        
            if (actions.equalsIgnoreCase("quit")) {
                System.out.println("Thanks for playing!");
                break;
            }
        
            if (actions.equalsIgnoreCase("help")) {
                switch (levelChoice) {
                case 1:
                    System.out.println("rrurd");
                    break;
                case 2:
                    System.out.println("dldlruruulllddduuurrrddllddluuudrrurul");
                    break;
                default:
                    System.out.println("No solution for this level...");
                    break;
                }
                continue;
            }
        
            for (char action : actions.toCharArray()) {
                switch (action) {
                case 'u':
                    controller.moveUp();
                    break;
                case 'd':
                    controller.moveDown();
                    break;
                case 'r':
                    controller.moveRight();
                    break;
                case 'l':
                    controller.moveLeft();
                    break;
                default:
                    System.out.println("Unknown action: " + action);
                }
            }
        }
        
        scanner.close();
    }

}
