
import java.net.URL
import java.text.SimpleDateFormat
import java.time.LocalDateTime
import java.time.format.DateTimeFormatter

import org.json4s._
import org.json4s.native.JsonMethods._

import scala.collection._
import scala.collection.mutable.ListBuffer
import scala.io.Source

object Main extends App {

  implicit val formats = DefaultFormats + new LocalDateTimeSerializer

  val json = parse(loadContent("https://cut.social/2017/hypnosisapp1/json")).extract[List[Result]]

  var map = mutable.Map[String, List[Result]]()
  json.foreach { item =>
    var list = map.getOrElse(item.subjectId, List()).to[ListBuffer]
    list += item
    map += (item.subjectId -> list.toList)
  }

  var hv = 0
  map foreach { item =>
    if (finishedHarvard(item._2)) {
      hv = hv + 1
      println(extractPhone(item._2))
    }
  }

  println(s"Harvard Participants = $hv")

  def loadContent(url: String): String = {
    val requestProperties = Map(
      "User-Agent" -> "Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.0)"
    )
    val connection = new URL(url).openConnection
    requestProperties.foreach({
      case (name, value) => connection.setRequestProperty(name, value)
    })

    Source.fromInputStream(connection.getInputStream).mkString
  }

  def extractPhone(res: List[Result]): Option[ProfileItem] = {
    res foreach { item =>
      val profile = item.content.profile
      if (profile.name.getOrElse("").trim.size>0 && profile.emailPhone.getOrElse("").trim.size>0)
        return Option(profile)
    }
    return None
  }

  def finishedHarvard(res: List[Result]): Boolean = {
    res foreach { item =>
      item.content.timestamps foreach { ts =>
        if (ts.action=="finished" && ts.session==201)
          return true
      }
    }
    return false
  }

  def extract99(items: List[Result]): List[String] = {
    var qs = mutable.ListBuffer[String]()
    items foreach { item =>
      item.content.surveys foreach { si =>
        if (si.question==99)
          qs += si.value
      }
    }
    return qs.toList
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