using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

public class Report
{
    [Key]
    [DatabaseGenerated(DatabaseGeneratedOption.Identity)]
    public int Id { get; set; }
    public required string UserId { get; set; }
    public int CategoryId { get; set; }
    public DateTime CreateDate { get; set; }
    public DateTime ReportDate { get; set; }
    public double? Latitude { get; set; }
    public double? Longitude { get; set; }
    public required List<string> Images { get; set; }
    public required string Description { get; set; }
    public string? InvolvedActorId { get; set; }
    public string? VictimActorId { get; set; }

}