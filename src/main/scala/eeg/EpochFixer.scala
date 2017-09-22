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

  val path = Option(s"/Users/morteza/Desktop/data/${subject.get}/${subject.get}_labels.txt")
  val trialsPath = Option(s"/Users/morteza/Desktop/data/${subject.get}/${subject.get}_trial_orders.txt")

  val content = loadFile(path.get)
  val trialsContent = loadFile(trialsPath.get)

  val trials = trialsContent.split("\n").drop(1) // drop header

  //implicit val system = ActorSystem("EpochFixerSystem")
  //implicit val materializer = ActorMaterializer()

  var codeMap = mutable.Map[Int, Int]()

  var sb = StringBuilder.newBuilder

  sb append "Latency Group Type Index"
  sb append "\n"

  var i = 0

  // drop header
  content.split("\n").drop(1).toList.foreach ( row => {
    val practice = i<40
    val s = new Scanner(row)
    var latency = s.nextDouble
    val order = s.nextInt
    val group = trials(Math.floor(i / 2).toInt)
    val eventType = if (codeMap.getOrElse(order, 0)==0) "start" else "rt"
    if (codeMap.getOrElse(order, 0) >= 1)
      codeMap.put(order, 0)
    else
      codeMap.put(order, codeMap.getOrElse(order, 0)+1)
    if ("start".equalsIgnoreCase(eventType)) latency = latency + {if (practice) 1.0 else 2.0} // move from start-of-fixation to start-of-stimulus
    sb append s"$latency $group $eventType $order\n"
    i += 1
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
