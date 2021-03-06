open Ostap

let parse infile =
  let s = Util.read infile in
  Language.Prog.parse_str s

let main = ()
    try
      let mode, filename =
        match Sys.argv.(1) with
        | "-s" -> `SM , Sys.argv.(2)
        | "-so"-> `SO , Sys.argv.(2)
        | "-o" -> `X86, Sys.argv.(2)
        | "-i" -> `Int, Sys.argv.(2)
        | _ -> raise (Invalid_argument "invalid flag")
      in
      match parse filename with
      | `Ok prog ->
        (match mode with
         | `X86 ->
           let basename = Filename.chop_suffix filename ".expr" in 
           X86.build prog basename
         | _ ->
           match mode with
           | `SM -> StackMachine.Interpreter.run (StackMachine.Compile.prog prog)
           | `SO ->
             let body = StackMachine.Compile.prog prog in
             let pr = function
               | StackMachine.S_COMM c -> Printf.printf "\n// %s\n" c
               | i -> Printf.printf "\t%s\n" (StackMachine.i_to_string i) in
             Array.iter pr body
           | `Int   -> Interpreter.Prog.eval prog
        )

      | `Fail er -> Printf.eprintf "%s\n" er
    with 
    | Invalid_argument _ ->
      Printf.printf "Usage: rc.byte <command> <name.expr>\n";
      Printf.printf "  <command> should be one of: -i, -s, -o, -so\n"
