import java.util.Date;
import java.text.SimpleDateFormat;

public class Work {
  int time;
  int score;
  
  int firstUpdate;
  int lastUpdate;
  
  long nextLogTime;
  
  int working;
  PrintWriter log;
  
  Work() {
    time = 0;
    score = 0;
    firstUpdate=-1;
    lastUpdate = millis();
    working = 1;
    log = createWriter("worksessions/work_"+new SimpleDateFormat("yyyy-MM-dd-HH-mm-ss").format(new Date())+".csv");
    log.println("runtime,typetime,score,working");
  }
  public void dispose() {
    log.flush();
    log.close();
  }
  int workSeconds() {
    return round(time/1000.0);
  }
  boolean isWorking() { return working==0?false:true; }
  void start() { working = 1; }
  void stop() { working = 0; }
  void reset() { working = 0; time = 0; }
  void update() { 
    if(firstUpdate==-1) {
      firstUpdate = millis();
      lastUpdate = firstUpdate;
      nextLogTime = lastUpdate + 1000;
    }
    if(millis() > nextLogTime) {
      nextLogTime += 1000;
      println("Added to log.");
      log.println(millis()+","+time+","+score+","+working);
      //log.flush();
    } else {
      println(millis()+" / "+nextLogTime);
    }
    if(isWorking())
      time += millis()-lastUpdate;
    lastUpdate = millis();
  }
  void draw() {
   pushMatrix();
    translate(width/2, height/2);
    scale(3); 
    fill(255,0,0);
    text(workSeconds()+"\n"+score, 0,0);
   popMatrix();
  }
}
