package eeg

import java.nio.charset.StandardCharsets
import java.nio.file.{Files, Paths}
import java.util.Scanner

import akka.actor.ActorSystem
import akka.stream.ActorMaterializer
import akka.stream.scaladsl._

import scala.collection.mutable
import scala.io.{Source => IOSource}

/**
  * To fix WinEEG/PsychoPy labels, and prepare epoch files for EEGLAB
  */
object EpochFixer extends App {
  val subject = Option(args(0))

  if (subject.isEmpty)
    System.exit(0)


  val path = Option(s"/Users/morteza/Desktop/data/${subject.get}/${subject.get}_eeg_labels.txt")
  val trialsPath = Option(s"/Users/morteza/Desktop/data/${subject.get}/${subject.get}_eeg_conditions.csv")

  val content = loadFile(path.get)
  val trialsContent = loadFile(trialsPath.get)

  val trials = trialsContent.split("\n")

  //implicit val system = ActorSystem("EpochFixerSystem")
  //implicit val materializer = ActorMaterializer()

  var codeMap = mutable.Map[Int, Int]()

  var sb = StringBuilder.newBuilder

  sb append "Latency Index Condition Trial"
  sb append "\n"

  var index = 1

  content.split("\n").toList.foreach ( row => {
    if (!row.contains("Latency")) {
      val s = new Scanner(row)
      var lat = s.nextDouble
      val typ = s.nextInt
      val trial = trials(Math.floor(index / 2).toInt)
      codeMap.put(typ, codeMap.getOrElse(typ, 0)+1)
      if (codeMap.getOrElse(typ, 0)>1)
        codeMap.put(typ, 0)
      val eventType = if (codeMap.getOrElse(typ, 0)==1) "start" else "rt"
      if ("start".equalsIgnoreCase(eventType)) lat = lat + 2.4
      sb append s"${lat} $typ $eventType $trial\n"
    }
    index += 1
  })

  writeToFile(s"/Users/morteza/Desktop/data/${subject.get}/${subject.get}_eeg_epochs.csv", sb.mkString)

  /*
  val flow = Source(content.split("\n").toList) via
    Flow[String].map(elem => elem) to
    Sink.foreach(println)

  flow.run()
  */

  def loadFile(path: String): String = {
    IOSource.fromFile(path, "UTF-8").mkString
  }

  def writeToFile(path: String, str: String) = {
    Files.write(Paths.get(path), str.getBytes(StandardCharsets.UTF_8))
  }
}
