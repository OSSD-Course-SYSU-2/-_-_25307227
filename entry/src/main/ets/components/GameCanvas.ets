
import { Bubble } from '../models/GameModels';
import { GameDataManager } from '../utils/GameDataManager';
/**
 * 泡泡组件
 */
@Component
export struct BubbleComponent {
  @Prop bubble: Bubble = new Bubble(0, 0, 0, '#FF6B6B');
  @Prop bubbleScale: number = 1;
  onPop?: (bubble: Bubble) => void;

  build() {
    Stack() {
      Circle()
        .width(this.bubble.radius * 2 * this.bubbleScale)
        .height(this.bubble.radius * 2 * this.bubbleScale)
        .fill(this.bubble.color)
        .shadow({
          radius: 10,
          color: '#40000000',
          offsetX: 2,
          offsetY: 2
        })
      
      Text(`${this.bubble.points}`)
        .fontSize(14)
        .fontColor(Color.White)
        .fontWeight(FontWeight.Bold)
    }
    .position({ x: this.bubble.x - this.bubble.radius, y: this.bubble.y - this.bubble.radius })
    .onClick(() => {
      if (this.onPop) {
        this.onPop(this.bubble);
      }
    })
  }
}

/**
 * 游戏画布组件
 */
@Component
export struct GameCanvas {
  @State bubbles: Bubble[] = [];
  @State score: number = 0;
  @State timeLeft: number = 60;
  @State isPlaying: boolean = false;
  @Prop canvasWidth: number = 350;
  @Prop canvasHeight: number = 500;
  @Prop levelNumber: number = 1;
  @Prop targetScore: number = 100;
  
  private gameManager: GameDataManager = GameDataManager.getInstance();
  private timer: number = -1;
  private bubbleIdCounter: number = 0;
  
  onGameOver?: (score: number, passed: boolean) => void;

  aboutToAppear() {
    this.initGame();
  }

  aboutToDisappear() {
    if (this.timer !== -1) {
      clearInterval(this.timer);
    }
  }

  /**
   * 初始化游戏
   */
  initGame(): void {
    this.score = 0;
    this.bubbles = [];
    this.bubbleIdCounter = 0;
    
    const level = this.gameManager.getCurrentLevel();
    this.timeLeft = level.timeLimit;
    this.generateBubbles(level.bubbleCount);
  }

  /**
   * 生成泡泡
   */
  generateBubbles(count: number): void {
    const colors = ['#FF6B6B', '#4ECDC4', '#45B7D1', '#FFA07A', '#98D8C8', '#F7DC6F', '#BB8FCE'];
    const sizeEquip = this.gameManager.player.equipments.get(3);
    const sizeBonus = sizeEquip ? sizeEquip.getEffect() : 1;
    
    for (let i = 0; i < count; i++) {
      const radius = (25 + Math.random() * 15) * sizeBonus;
      const x = radius + Math.random() * (this.canvasWidth - radius * 2);
      const y = radius + Math.random() * (this.canvasHeight - radius * 2);
      const color = colors[Math.floor(Math.random() * colors.length)];
      const points = Math.floor(10 + Math.random() * 20);
      
      this.bubbles.push(new Bubble(this.bubbleIdCounter++, x, y, color, points));
    }
  }

  /**
   * 开始游戏
   */
  startGame(): void {
    this.isPlaying = true;
    this.initGame();
    this.startTimer();
  }

  /**
   * 开始计时器
   */
  startTimer(): void {
    this.timer = setInterval(() => {
      if (this.timeLeft > 0) {
        this.timeLeft--;
        
        // 随机生成新泡泡
        if (Math.random() < 0.3 && this.bubbles.length < 30) {
          this.addRandomBubble();
        }
      } else {
        this.endGame();
      }
    }, 1000);
  }

  /**
   * 添加随机泡泡
   */
  addRandomBubble(): void {
    const colors = ['#FF6B6B', '#4ECDC4', '#45B7D1', '#FFA07A', '#98D8C8'];
    const radius = 25 + Math.random() * 15;
    const x = radius + Math.random() * (this.canvasWidth - radius * 2);
    const y = radius + Math.random() * (this.canvasHeight - radius * 2);
    const color = colors[Math.floor(Math.random() * colors.length)];
    const points = Math.floor(10 + Math.random() * 20);
    
    this.bubbles.push(new Bubble(this.bubbleIdCounter++, x, y, color, points));
  }

  /**
   * 点击泡泡
   */
  popBubble(bubble: Bubble): void {
    const index = this.bubbles.findIndex(b => b.id === bubble.id);
    if (index !== -1) {
      this.bubbles.splice(index, 1);
      
      // 计算积分（考虑装备加成）
      const scoreEquip = this.gameManager.player.equipments.get(1);
      const scoreBonus = scoreEquip ? scoreEquip.getEffect() : 1;
      const earnedScore = Math.floor(bubble.points * scoreBonus);
      
      this.score += earnedScore;
      
      // 添加金币
      const coinEquip = this.gameManager.player.equipments.get(2);
      const coinBonus = coinEquip ? coinEquip.getEffect() : 1;
      this.gameManager.player.addCoins(Math.floor(earnedScore * 0.1 * coinBonus));
    }
  }

  /**
   * 结束游戏
   */
  endGame(): void {
    this.isPlaying = false;
    if (this.timer !== -1) {
      clearInterval(this.timer);
      this.timer = -1;
    }
    
    const passed = this.score >= this.targetScore;
    if (this.onGameOver) {
      this.onGameOver(this.score, passed);
    }
  }

  build() {
    Stack() {
      // 游戏背景
      Column() {
        // 顶部信息栏
        Row() {
          Text(`关卡: ${this.levelNumber}`)
            .fontSize(16)
            .fontColor('#333')
          
          Blank()
          
          Text(`目标: ${this.targetScore}`)
            .fontSize(16)
            .fontColor('#333')
          
          Blank()
          
          Text(`得分: ${this.score}`)
            .fontSize(18)
            .fontColor('#FF6B6B')
            .fontWeight(FontWeight.Bold)
          
          Blank()
          
          Text(`时间: ${this.timeLeft}s`)
            .fontSize(16)
            .fontColor(this.timeLeft <= 10 ? '#FF0000' : '#333')
        }
        .width('100%')
        .padding(10)
        .backgroundColor('#F5F5F5')
        
        // 游戏区域
        Stack() {
          ForEach(this.bubbles, (bubble: Bubble) => {
            BubbleComponent({
              bubble: bubble,
              onPop: (b: Bubble) => {
                this.popBubble(b);
              }
            })
          }, (bubble: Bubble) => bubble.id.toString())
        }
        .width(this.canvasWidth)
        .height(this.canvasHeight)
        .backgroundColor('#E8F4F8')
        .borderRadius(10)
        
        // 开始按钮
        if (!this.isPlaying) {
          Button('开始游戏')
            .width(150)
            .height(50)
            .fontSize(20)
            .backgroundColor('#4ECDC4')
            .onClick(() => {
              this.startGame();
            })
        }
      }
      .width('100%')
      .height('100%')
    }
  }
}
