
import java.net.URL
import java.nio.charset.StandardCharsets
import java.nio.file.{Files, Paths}
import java.text.SimpleDateFormat
import java.time.LocalDateTime
import java.time.format.DateTimeFormatter

import org.json4s.JsonAST.JValue
import org.json4s._
import org.json4s.native.JsonMethods._
import org.json4s.scalap.scalasig.StringBytesPair

import scala.collection._
import scala.collection.mutable.ListBuffer
import scala.io.Source

object Main extends App {

  implicit val formats = DefaultFormats + new LocalDateTimeSerializer

  val url = "https://cut.social/2017/hypnosisapp1/json"
  val json = parse(loadContent(url)).extract[List[Result]]

  var map = mutable.Map[String, List[Result]]()
  json.foreach { item =>
    var list = map.getOrElse(item.subjectId, List()).to[ListBuffer]
    list += item
    map += (item.subjectId -> list.toList)
  }

  var sb = StringBuilder.newBuilder

  sb append """name,phone,device_id,harvard,oakley,q10001,q10002,q10003,q10004,q10005,q10006,q10007,q10008,"""
  sb append """q20001,q20002,q20003,q20004,q20005,q20006,q20007,q20008,q20009,q20010,q20011,q20012,"""
  sb append """q30002,q30003,q30004,q30005,q30006,q30007,q30008,q30009,q30010"""
  sb append "\n"
  map foreach { item =>
    val harv = Extractors.session(item._2, 201)
    val oakl = Extractors.session(item._2, 301)

    if (harv || oakl) {
      val v = Extractors.profile(item._2)
      if (v.isDefined) {
        var row = StringBuilder.newBuilder
        row append Extractors.question(item._2, 10001) append ","
        row append Extractors.question(item._2, 10002) append ","
        row append Extractors.question(item._2, 10003) append ","
        row append Extractors.question(item._2, 10004) append ","
        row append Extractors.question(item._2, 10005) append ","
        row append Extractors.question(item._2, 10006) append ","
        row append Extractors.question(item._2, 10007) append ","
        row append Extractors.question(item._2, 10008) append ","

        row append Extractors.question(item._2, 20001) append ","
        row append Extractors.question(item._2, 20002) append ","
        row append Extractors.question(item._2, 20003) append ","
        row append Extractors.question(item._2, 20004) append ","
        row append Extractors.question(item._2, 20005) append ","
        row append Extractors.question(item._2, 20006) append ","
        row append Extractors.question(item._2, 20007) append ","
        row append Extractors.question(item._2, 20008) append ","
        row append Extractors.question(item._2, 20009) append ","
        row append Extractors.question(item._2, 20010) append ","
        row append Extractors.question(item._2, 20011) append ","
        row append Extractors.question(item._2, 20012) append ","

        row append Extractors.question(item._2, 30002) append ","
        row append Extractors.question(item._2, 30003) append ","
        row append Extractors.question(item._2, 30004) append ","
        row append Extractors.question(item._2, 30005) append ","
        row append Extractors.question(item._2, 30006) append ","
        row append Extractors.question(item._2, 30007) append ","
        row append Extractors.question(item._2, 30008) append ","
        row append Extractors.question(item._2, 30009) append ","
        row append Extractors.question(item._2, 30010) append ""

        sb append s"""${v.get.name.getOrElse("")}, ${v.get.emailPhone.getOrElse("")}, ${item._1}, $harv, $oakl, ${row.result}"""
        sb append "\n"
      }
    }
  }

  writeToFile(sb.result)

  def loadContent(url: String): String = {
    //Source.fromFile("/Users/morteza/Desktop/hypnosisapp1_201708281.json").mkString
    val requestProperties = Map(
      "User-Agent" -> "Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.0)"
    )
    val connection = new URL(url).openConnection
    requestProperties.foreach({
      case (name, value) => connection.setRequestProperty(name, value)
    })

    Source.fromInputStream(connection.getInputStream).mkString
  }

  def writeToFile(str: String) = {
    Files.write(Paths.get("/Users/morteza/Desktop/hypnosisapp1_201708281.csv"), str.getBytes(StandardCharsets.UTF_8))
  }
}

class LocalDateTimeSerializer extends CustomSerializer[LocalDateTime](format => (
  {
    case JString(str) =>
      import java.time.format.DateTimeFormatter
      val formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss")
      LocalDateTime.parse(str.substring(0,19), formatter)

  }, {
  case x: LocalDateTime => JString(x.toString)
}
))