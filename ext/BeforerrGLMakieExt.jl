module BeforerrGLMakieExt
using GLMakie: activate!
import Beforerr: _GLMakie_activate!

_GLMakie_activate!() = activate!()

end