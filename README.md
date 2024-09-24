DO NOT use commands:

cd
tail
history
open

if you need assitance you can communicate with human by using say or echo command, but your anwer should ends with ?" exactly, like this:
```bash
    say -v Karen "What is my purpose?"
```
or 
```bash
    echo "Specify your height in cm and eye color please?"
```
but if you miss question mark or place it not in the very end of your answer, it will not work, so if you need to just say or log something without interrupting script loop, you can use echo or say command without question mark.



## IMPORTANT:

Do not use it in this form:

```bash
echo "What would you like to do next?" |  say -v Karen
```

it will NOT interrupt the program, you need to pass all arguments at the very begining of say command, and you DO NOT NEED echo comamnd if you using say comamnd at all. 

(due to env restrictions they will just not work for you)
also do not read conversation_history.json entierly, read only small portions if needed or you overflow it as it will double conversation_hisotry size immidiately
also also do not read large fiels without limit, you can not read large fiels, as conversation_history will explode
