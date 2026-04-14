/**
 * 泡泡数据模型
 */
export class Bubble {
  id: number = 0;
  x: number = 0;
  y: number = 0;
  radius: number = 30;
  color: string = '#FF6B6B';
  isAlive: boolean = true;
  points: number = 10;

  constructor(id: number, x: number, y: number, color: string, points: number = 10) {
    this.id = id;
    this.x = x;
    this.y = y;
    this.color = color;
    this.points = points;
  }
}

/**
 * 关卡数据模型
 */
export class Level {
  levelNumber: number = 1;
  targetScore: number = 100;
  bubbleCount: number = 20;
  timeLimit: number = 60; // 秒
  bubbleColors: string[] = ['#FF6B6B', '#4ECDC4', '#45B7D1', '#FFA07A', '#98D8C8'];
  reward: number = 50; // 通关奖励金币

  constructor(level: number, target: number, bubbles: number, time: number, reward: number = 50) {
    this.levelNumber = level;
    this.targetScore = target;
    this.bubbleCount = bubbles;
    this.timeLimit = time;
    this.reward = reward;
  }
}

/**
 * 道具数据模型
 */
export class Item {
  id: number = 0;
  name: string = '';
  description: string = '';
  price: number = 0;
  icon: string = '';
  effect: string = ''; // 'double_score', 'time_extend', 'magnet', 'bomb'
  duration: number = 0; // 持续时间（秒）
  purchased: boolean = false;

  constructor(id: number, name: string, desc: string, price: number, effect: string, duration: number = 0) {
    this.id = id;
    this.name = name;
    this.description = desc;
    this.price = price;
    this.effect = effect;
    this.duration = duration;
  }
}

/**
 * 装备数据模型
 */
export class Equipment {
  id: number = 0;
  name: string = '';
  description: string = '';
  basePrice: number = 0;
  currentLevel: number = 1;
  maxLevel: number = 10;
  effectPerLevel: number = 0.1; // 每级提升效果

  constructor(id: number, name: string, desc: string, price: number, effect: number = 0.1) {
    this.id = id;
    this.name = name;
    this.description = desc;
    this.basePrice = price;
    this.effectPerLevel = effect;
  }

  getUpgradePrice(): number {
    return Math.floor(this.basePrice * Math.pow(1.5, this.currentLevel - 1));
  }

  getEffect(): number {
    return 1 + (this.currentLevel - 1) * this.effectPerLevel;
  }
}

/**
 * 玩家数据模型
 */
export class Player {
  totalScore: number = 0;
  currentLevel: number = 1;
  coins: number = 100; // 初始金币
  highestScore: number = 0;
  items: Map<number, number> = new Map(); // 道具ID -> 数量
  equipments: Map<number, Equipment> = new Map(); // 装备ID -> 装备

  addScore(score: number): void {
    this.totalScore += score;
    if (this.totalScore > this.highestScore) {
      this.highestScore = this.totalScore;
    }
  }

  addCoins(coins: number): void {
    this.coins += coins;
  }

  spendCoins(coins: number): boolean {
    if (this.coins >= coins) {
      this.coins -= coins;
      return true;
    }
    return false;
  }
}
