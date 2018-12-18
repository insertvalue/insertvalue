title: Spring的自定义标签
author: 冯平宇
tags:
  - JAVA
  - Spring
categories:
  - 技术
date: 2018-12-18 14:02:00
---
# Spring的自定义标签

---

> Spring为自定义xml标签加载提供了扩展。用户可自定义标签并注册到Spring的bean容器中。实现较为复杂的bean加载解析。

## 技术要点：

 - XML、DTD、XSD

<!-- more -->

### 什么是XML（EXtensible Markup Language）？

 - XML 指可扩展标记语言（EXtensible Markup Language）
 - XML 是一种标记语言，很类似 HTML
 - XML 的设计宗旨是传输数据，而非显示数据
 - XML 标签没有被预定义。您需要自行定义标签。
 - XML 被设计为具有自我描述性。
 - XML 是 W3C 的推荐标准

### 什么是DTD（Document Type Definition）？
 - 文档类型定义（DTD）可定义合法的XML文档构建模块。它使用一系列合法的元素来定义文档的结构。DTD 可被成行地声明于 XML 文档中，也可作为一个外部引用。

### 什么是XSD（XML Schema Definition）？
 - XML Schema 的作用是定义 XML 文档的合法构建模块，类似 DTD。

### XSD是DTD的继任者
我们认为 XML Schema 很快会在大部分网络应用程序中取代 DTD。理由如下：
> * XML Schema 可针对未来的需求进行扩展
> * XML Schema 更完善，功能更强大
> * XML Schema 基于 XML 编写
> * XML Schema 支持数据类型
> * XML Schema 支持命名空间

## 自定义Spring标签

### 自定义xsd：

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<xsd:schema xmlns="http://www.fpy.org/schema/beans/test"
			xmlns:xsd="http://www.w3.org/2001/XMLSchema"
			targetNamespace="http://www.fpy.org/schema/beans/test"
			elementFormDefault="qualified">
	<xsd:element name="testBean">
		<xsd:complexType>
			<xsd:attribute name="id" type="xsd:string" use="required" form="unqualified"/>
			<xsd:attribute name="name" type="xsd:string" use="required" form="unqualified"/>
			<xsd:attribute name="age" type="xsd:integer" use="required" form="unqualified"/>
		</xsd:complexType>
	</xsd:element>
</xsd:schema>
```

`xmlns`：默认命名空间，类似import
`targetNamespace`：定义文件内标签所属命名空间，类似package
`elementFormDefault`：在XML文档中使用局部元素时，必须使用限定短名作为前缀

### 定义namespace与handler映射关系文件：

Spring解析xml文件时，需要根据节点所在命名空间对应的处理器来解析。Spring默认从**resources/META-INF/spring.handlers**文件获取映射关系。用户也可自定义映射文件路径。

#### spring.handlers
```
http\://www.fpy.org/schema/beans/test=com.example.demo.xsd.CustomNamespaceHandler
```

### 定义NamespaceHandler，解析自定义标签
继承**NamespaceHandlerSupport**类，在**init()**方法中注册自定义标签的解析器，如**testBean**标签使用**TestBeanDefinitionParser**进行解析。

**TestBeanDefinitionParser**实现**BeanDefinitionParser**接口，在**parse()**方法中添加自定义解析规则，并注册beanDefinition
```java
public class CustomNamespaceHandler extends NamespaceHandlerSupport {
    @Override
    public void init() {
        // 注册标签parser
        registerBeanDefinitionParser("testBean", new TestBeanDefinitionParser());
    }

    private static class TestBeanDefinitionParser implements BeanDefinitionParser {

        @Override
        public BeanDefinition parse(Element element, ParserContext parserContext) {
            RootBeanDefinition definition = new RootBeanDefinition();
            definition.setBeanClass(TestBean.class);

            MutablePropertyValues mpvs = new MutablePropertyValues();
            mpvs.add("name", element.getAttribute("name"));
            mpvs.add("age", element.getAttribute("age"));
            definition.setPropertyValues(mpvs);

            parserContext.getRegistry().registerBeanDefinition(element.getAttribute("id"), definition);
            return null;
        }
    }
}
```

### 定义自定义标签xsd映射路径

xml文件xsi:schemaLocation定义了命名空间对应的xsd路径，当改路径为http文档时，避免因网络问题导致加载失败，我们可在本地定义namespace和xsd的映射关系。Spring默认从**resources/META-INF/spring.schemas**文件获取映射关系。用户也可自定义映射文件路径。

```xml
<beans xmlns="http://www.springframework.org/schema/beans"
       xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
       xmlns:test="http://www.fpy.org/schema/beans/test"
       xsi:schemaLocation="http://www.springframework.org/schema/beans http://www.springframework.org/schema/beans/spring-beans-2.0.xsd
       http://www.fpy.org/schema/beans/test http://www.fpy.org/schema/custom_namespace/CustomNamespaceHandlerTests.xsd"
       default-lazy-init="true">
    <test:testBean id="testBean" name="fengpingyu" age="28"/>
</beans>
```

将`http://www.fpy.org/schema/custom_namespace/CustomNamespaceHandlerTests.xsd`映射到本地文件
#### spring.schemas
```
http\://www.fpy.org/schema/custom_namespace/CustomNamespaceHandlerTests.xsd=custom_namespace/CustomNamespaceHandlerTests.xsd
```

### 测试方法

```java
public class CustomNsTests {

    // namespace和handler映射关系文件
    private static final String NS_PROPS = "custom_namespace/CustomNamespaceHandlerTests.properties";
    // 测试xml文件
    private static final String NS_XML = "custom_namespace/CustomNamespaceHandlerTests-context.xml";
    // xml的xsd文件
    private static final String TEST_XSD = "custom_namespace/CustomNamespaceHandlerTests.xsd";

    @Test
    public void testCustomNamespaceHandler() {
        DefaultListableBeanFactory factory = new DefaultListableBeanFactory();
        NamespaceHandlerResolver nhr = new DefaultNamespaceHandlerResolver(CustomNsTests.class.getClassLoader(), NS_PROPS);
        XmlBeanDefinitionReader bd = new XmlBeanDefinitionReader(factory);
        bd.setValidationMode(XmlBeanDefinitionReader.VALIDATION_XSD);
        // 自定义handlers文件路径
        bd.setNamespaceHandlerResolver(nhr);
        // 自定义schemas文件路径
        bd.setEntityResolver(new DummySchemaResolver());
        bd.loadBeanDefinitions(NS_XML);
        TestBean testBean = (TestBean) factory.getBean("testBean");
        System.out.println(JSONObject.toJSONString(testBean));
    }

    /**
     * 自定义schemas路径解析器
     * 默认从META-INF/spring.schemas文件读取，读取不到时就自定义路径读取
     */
    private final class DummySchemaResolver extends PluggableSchemaResolver {

        public DummySchemaResolver() {
            super(CustomNsTests.class.getClassLoader());
        }

        @Override
        public InputSource resolveEntity(String publicId, String systemId) throws IOException {
            InputSource source = super.resolveEntity(publicId, systemId);
            if (source == null) {
                Resource resource = new ClassPathResource(TEST_XSD);
                source = new InputSource(resource.getInputStream());
                source.setPublicId(publicId);
                source.setSystemId(systemId);
            }
            return source;
        }
    }
}

```