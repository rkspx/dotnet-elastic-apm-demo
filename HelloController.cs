using Microsoft.AspNetCore.Mvc;

namespace APMDemo.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class HelloController : ControllerBase
    {
        [HttpGet]
        public Task<string> Get()
        {
            return Task.FromResult("Hello, World!");
        }
    }
}