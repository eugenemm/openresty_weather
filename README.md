1. Building services

```
docker-compose build
```

2. Run

```
docker-compose up -d
```

3. Testing: open URL in browser or make curl request

```
http://localhost:8090/hello?city={city_name}
```

examples:

```
http://localhost:8090/hello?city=Курск
http://localhost:8090/hello?city=Москва
http://localhost:8090/hello?city=Краснодар
```

4. Stop services

```
docker-compose down
```