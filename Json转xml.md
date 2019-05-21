# Json转xml

### fastjson,gosn应该很方便的搞定吧 T-T

要求要用 jackson，咋办！jackson没用过！baidu一下，emmm,什么javaBean啊，不太方便！

想了一下，换个方式 json字符串-->Map -->xml 

(```)
import java.io.BufferedReader;
import java.io.FileReader;
import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.stream.Collectors;

import org.codehaus.jackson.map.ObjectMapper;

public class Json2xml {
	
	public static void main(String[] args) {
		System.out.println("转化得到的xml: \n" + jsonStrToMap(readFile()));
	}
	
	/**
	 * 将json格式字符串转化成Map
	 * @param jsonStr json格式字符串
	 * @return
	 */
	public static String jsonStrToMap(String jsonStr) {
		ObjectMapper om = new ObjectMapper();
		try {
			LinkedHashMap<String, ?> node = om.readValue(jsonStr,LinkedHashMap.class);
			return callMapToXML(node);
		} catch (IOException e) {
			e.printStackTrace();
		}
		return null;
	}
	
	/**
	 * 调用map转xml方法
	 * @param map 需要转化的map
	 * @return
	 */
	public static String callMapToXML(Map<String, ?> map) {
		// System.out.println("将Map转成Xml, Map：\n" + map.toString());
		// xml字符串
		StringBuffer xmlStr = new StringBuffer();
		// xml头和根标签
		xmlStr.append("<?xml version=\"1.0\" encoding=\"UTF-8\"?><Json2Xml>");
		// 执行转换操作
		mapToXML(map, xmlStr);
		xmlStr.append("</Json2Xml>");
		// System.out.println("将Map转成Xml, Xml：\n" + xmlStr.toString());
		try {
			return xmlStr.toString();
		} catch (Exception e) {
			System.out.println(e);
		}
		return null;
	}
 
	/**
	 * 将Map转换成xml
	 * @param map 需要转换到map
	 * @param xmlStr 带有xml根标签字符串
	 */
	public static void mapToXML(Map<String, ?> map, StringBuffer xmlStr) {
		// Map的key集合
		Set<String> keySet = map.keySet();
		for (Iterator<String> keyIterator = keySet.iterator(); keyIterator.hasNext();) {
			String key = (String) keyIterator.next();
			Object value = map.get(key);
			if (null == value) {
				value = "";
			}
			if (value instanceof List) {
				List listValue = (ArrayList<?>)value;
				for (int i = 0; i < listValue.size(); i++) {
					xmlStr.append("<").append(key).append(">");
					Object innerValue = listValue.get(i);
					if(innerValue instanceof HashMap) {
						// listValue里面嵌套的是Map,则递归
						HashMap<String, ?> hm = (HashMap) innerValue;
						mapToXML(hm, xmlStr);
					}else {
						// listValue里面嵌套的不是Map，将listValue的值按“,”分隔直接放到listValue标签下
						xmlStr.append(listValue.stream().collect(Collectors.joining(",")).toString());
						xmlStr.append("</").append(key).append(">");
						break;
					}
					xmlStr.append("</").append(key).append(">");
				}
			} else {
				if (value instanceof HashMap) {
					xmlStr.append("<").append(key).append(">");
					mapToXML((HashMap) value, xmlStr);
					xmlStr.append("</").append(key).append(">");
				} else {
					xmlStr.append("<").append(key).append(">");
					xmlStr.append(value);
					xmlStr.append("</").append(key).append(">");
				}
			}
		}
	}
	
	public static String readFile() {
        String pathname = "json.json";
        StringBuffer jsonStr = new StringBuffer();
        try (FileReader reader = new FileReader(pathname);
             BufferedReader br = new BufferedReader(reader) // 建立一个对象，它把文件内容转成计算机能读懂的语言
        ) {
            String line;
            //网友推荐更加简洁的写法
            while ((line = br.readLine()) != null) {
                // 一次读入一行数据
                jsonStr.append(line.trim());
            }
        } catch (IOException e) {
            e.printStackTrace();
        }
        System.out.println("读取到的JSON数据：\n" + jsonStr.toString());
        return jsonStr.toString();
    }

}

(```)

