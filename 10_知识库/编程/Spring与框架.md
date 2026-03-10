## Spring Core
### Spring 框架中 Bean 的作用域有哪些？
Spring 框架中定义了多种 Bean 作用域，主要包括：
1. **singleton**：默认作用域，在整个 Spring IoC 容器中只存在一个 Bean 实例。
2. **prototype**：每次请求（通过 getBean 或注入）都会创建一个新的 Bean 实例。
3. **request**：在 Web 应用中，每个 HTTP 请求会创建一个 Bean 实例，仅在该请求内有效。
4. **session**：在 Web 应用中，每个 HTTP Session 会创建一个 Bean 实例。
5. **application**：在 Web 应用中，每个 ServletContext 生命周期内创建一个 Bean 实例。
6. **websocket**：在 WebSocket 会话生命周期内有效。