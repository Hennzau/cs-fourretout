package hmi;

import java.awt.BorderLayout;
import java.awt.Dimension;
import java.awt.Graphics;
import java.awt.Image;
import java.awt.Toolkit;
import java.awt.event.KeyEvent;
import java.awt.event.KeyListener;
import java.io.File;
import java.io.IOException;

import javax.imageio.ImageIO;
import javax.swing.JButton;
import javax.swing.JComboBox;
import javax.swing.JFrame;
import javax.swing.JOptionPane;
import javax.swing.JPanel;
import javax.swing.SwingUtilities;

import com.modeliosoft.modelio.javadesigner.annotations.objid;

import controller.Controller;
import entities.Cell;
import entities.Position;
import hmi.levels.Level1;
import hmi.levels.Level2;
import hmi.levels.Level3;
import hmi.levels.Level4;
import hmi.levels.Level5;

@objid("1292c2df-27b8-4e25-b5de-bf49bab222aa")
public class Window extends JFrame implements KeyListener {
	private JPanel gridPanel;
	private JComboBox<String> levelSelector;

	private JButton nextLevelButton;
	private JPanel victoryPanel;

	private int currentLevel = 1;
	private Controller controller;

	private Image player;
	private Image floor;
	private Image target;
	private Image wall;
	private Image box;

	@objid("d13ed207-8e60-4107-93c3-b21085f128c8")
	public static void main(String[] args) {
		SwingUtilities.invokeLater(() -> {
			new Window().setVisible(true);
		});
	}

	public Window() {
		setTitle("Sokoban");
		setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
		setLayout(new BorderLayout());

		try {
			player = ImageIO.read(new File("images/Man.jpg"));
			floor = ImageIO.read(new File("images/EmptyFloor.jpg"));
			target = ImageIO.read(new File("images/Goal.jpg"));
			wall = ImageIO.read(new File("images/Wall.jpg"));
			box = ImageIO.read(new File("images/Box.jpg"));
		} catch (IOException e) {
			e.printStackTrace();
		}

		try {
			controller = new Controller(Level1.buildFromString());
		} catch (Exception e) {
			e.printStackTrace();
			return;
		}

		levelSelector = new JComboBox<String>(new String[] { "Level 1", "Level 2", "Level 3", "Level 4", "Level 5" });
		levelSelector.addActionListener(e -> loadLevel(levelSelector.getSelectedIndex() + 1));
		add(levelSelector, BorderLayout.NORTH);

		gridPanel = new JPanel() {
			@Override
			protected void paintComponent(Graphics g) {
				super.paintComponent(g);
				for (int x = 0; x < controller.getLevel().getGrid().getWidth(); x++) {
					for (int y = 0; y < controller.getLevel().getGrid().getHeight(); y++) {
						// Check if player
						if (controller.getLevel().getPlayer().getPosition().equals(new Position(x, y))) {
							g.drawImage(player, x * 32, y * 32, 32, 32, this);
							continue;
						}
						// Check if box
						if (controller.getLevel().getBoxes().get(new Position(x, y)) != null) {
							g.drawImage(box, x * 32, y * 32, 32, 32, this);
							continue;
						}
						// Otherwise it's a regular static cell

						Cell cell;
						try {
							cell = controller.getLevel().getGrid().getCell(new Position(x, y));
						} catch (Exception e) {
							e.printStackTrace();
							continue;
						}

						switch (cell) {
						case WALL:
							g.drawImage(wall, x * 32, y * 32, 32, 32, this);
							break;
						case FLOOR:
							g.drawImage(floor, x * 32, y * 32, 32, 32, this);
							break;
						case TARGET:
							g.drawImage(target, x * 32, y * 32, 32, 32, this);
							break;
						default:
							break;
						}
					}
				}
			}
		};

		add(gridPanel, BorderLayout.CENTER);

		victoryPanel = new JPanel();

		nextLevelButton = new JButton("Next Level");
		nextLevelButton.addActionListener(e -> goToNextLevel());
		victoryPanel.add(nextLevelButton);

		add(victoryPanel, BorderLayout.SOUTH);
		victoryPanel.setVisible(false);

		gridPanel.addKeyListener(this);
		gridPanel.setFocusable(true);
		gridPanel.setFocusTraversalKeysEnabled(true);
		gridPanel.requestFocusInWindow();

		loadLevel(currentLevel);
	}

	private void loadLevel(int level) {
		victoryPanel.setVisible(false);
		
		currentLevel = level;

		try {
			switch (currentLevel) {
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
				break;
			}
		} catch (Exception e) {
			e.printStackTrace();
		}

		setSize(16 + 32 * controller.getLevel().getGrid().getWidth(),
				64 + 32 * controller.getLevel().getGrid().getHeight());

		Toolkit toolkit = Toolkit.getDefaultToolkit();
		Dimension screenSize = toolkit.getScreenSize();

		int width = getWidth();
		int height = getHeight();

		setLocation((screenSize.width - width) / 2, (screenSize.height - height) / 2);

		gridPanel.repaint();

		gridPanel.requestFocusInWindow();

		System.out.println("Level " + level + " loaded!");
	}

	private void goToNextLevel() {
		if (currentLevel < 5) {
			currentLevel++;
			levelSelector.setSelectedIndex(currentLevel - 1);
			
			loadLevel(currentLevel);
		} else {
			JOptionPane.showMessageDialog(this, "Congratulations! You've completed all levels!");
		}
	}

	public void showVictoryScreen() {
		victoryPanel.setVisible(true);
	}

	@Override
	public void keyTyped(KeyEvent e) {
		// TODO Auto-generated method stub

	}

	@Override
	public void keyPressed(KeyEvent e) {
		switch (e.getKeyCode()) {
		case KeyEvent.VK_UP -> controller.moveUp();
		case KeyEvent.VK_DOWN -> controller.moveDown();
		case KeyEvent.VK_LEFT -> controller.moveLeft();
		case KeyEvent.VK_RIGHT -> controller.moveRight();
		}

		gridPanel.repaint();

		if (controller.checkVictory()) {
			showVictoryScreen();
		}
	}

	@Override
	public void keyReleased(KeyEvent e) {
		// TODO Auto-generated method stub

	}
}
