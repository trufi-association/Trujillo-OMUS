public class Report
{
    public Guid Id { get; set; }
    public Guid UserId { get; set; }
    public Guid CategoryId { get; set; }
    public DateTime CreateDate { get; set; }
    public DateTime ReportDate { get; set; }
    public double? Latitude { get; set; }
    public double? Longitude { get; set; }
    public required List<string> Images { get; set; }
    public required string Description { get; set; }
    public string? InvolvedActorId { get; set; }
    public string? VictimActorId { get; set; }

}