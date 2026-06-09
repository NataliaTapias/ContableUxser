using ContableUxser.Application.Features.Ventas.Commands;
using ContableUxser.Application.Features.Ventas.Queries;
using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace ContableUxser.Api.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize]
public class VentasController : ControllerBase
{
    private readonly IMediator _mediator;

    public VentasController(IMediator mediator)
    {
        _mediator = mediator;
    }

    [HttpPost]
    public async Task<IActionResult> Create([FromBody] CreateVentaCommand command)
    {
        var result = await _mediator.Send(command);
        return result.Exitoso
            ? Ok(result)
            : BadRequest(result);
    }

    [HttpPost("bulk-sync")]
    public async Task<IActionResult> BulkSync([FromBody] BulkSyncVentasCommand command)
    {
        var result = await _mediator.Send(command);
        return result.Exitoso
            ? Ok(result)
            : BadRequest(result);
    }

    [HttpGet]
    public async Task<IActionResult> GetAll([FromQuery] GetVentasQuery query)
    {
        var result = await _mediator.Send(query);
        return Ok(result);
    }
}
